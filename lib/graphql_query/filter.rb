require_relative 'constants'

module GraphqlQuery
  module Filter
    include Constants

    def include_filter_arguments(type, args)
      args.each do |key|
        value = FILTERS[key]
        raise ArgumentError, "Filter #{key} does not exist" if value.nil?

        argument key,
          value[:transform_type].call(type),
          description: value[:description],
          required: false
      end
    end
  end
end
