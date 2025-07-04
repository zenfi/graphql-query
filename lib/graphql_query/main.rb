require_relative 'constants'

module GraphqlQuery
  class Main
    include Constants

    attr_reader :args, :relation

    def initialize(relation, args)
      @relation = relation
      @args = args.to_h
    end

    def to_relation
      operated_relation
    end

    private

    def table_name
      relation.table_name
    end

    def filters
      @filters ||= args[:filter_by]&.to_h
    end

    def sorters
      @sorters ||= (args[:sort_by].is_a?(Array) ? args[:sort_by] : [args[:sort_by]])
        .compact
        .map(&:to_h)
    end

    def filtered_relation
      @filtered_relation ||= relation
        .where(nil)
        .then { |prev| apply_filters(prev) }
        .then { |prev| apply_search(prev) }
    end

    def operated_relation
      @operated_relation ||= filtered_relation
        .then { |prev| apply_sorter(prev) }
    end

    def apply_filters(results)
      filters&.each do |field, key_filters|
        key_filters&.each do |filter, value|
          key = "#{table_name}.#{field}"
          results = FILTERS[filter][:statement].call(results, key, value)
        end
      end
      results
    end

    def apply_sorter(results)
      order = sorters.compact
        .filter { |sort| !sort[:field].empty? && !sort[:order].empty? }
        .map { |sort| sort.merge(field: parse_sort_field(sort[:field])) }
        .map { |sort| sort.merge(order: sort[:order].to_s.upcase) }
        .map { |sort| "#{sort[:field]} #{sort[:order]}" }
        .join(', ')

      order.empty? ? results : results.order(order)
    end

    def parse_sort_field(raw)
      parsed = underscore(raw.to_s)
      return 'RANDOM()' if parsed == 'random'
      parsed
    end

    def apply_search(results)
      search_by = args[:search_by].to_h.compact
      return results if search_by.empty?

      filter = nil
      search_by.each do |field, value|
        where = relation.where("#{table_name}.#{field} ILIKE ?", "%#{value}%")
        filter = filter.nil? ? where : filter.or(where)
      end

      results.and(filter)
    end

    def underscore(camel_cased_word)
      return camel_cased_word.to_s.dup unless /[A-Z-]|::/.match?(camel_cased_word)
      word = camel_cased_word.to_s.gsub("::", "/")
      word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end
