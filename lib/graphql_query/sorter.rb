# rubocop:disable Style/ClassVars
module GraphqlQuery
  module Sorter
    def self.enum_class
      @@enum_class
    end

    def self.enum_class=(enum_class)
      @@enum_class = enum_class
      create_order_enum
    end

    def self.create_order_enum
      @@order_enum = Class.new(@@enum_class)
      @@order_enum.graphql_name('OrderEnum')
      @@order_enum.value('ASC', 'Ascending order')
      @@order_enum.value('DESC', 'Descending order')
    end

    def include_order_arguments(model_name, fields)
      graphql_name "#{model_name}SortInput"

      sortable_field = Object.const_set("#{model_name}SortInput", Class.new(@@enum_class))
      sortable_field.graphql_name("#{model_name}SortableField")
      fields.each do |key|
        sortable_field.value key, "Sort by #{key}"
      end

      argument :field,
        sortable_field,
        description: 'Sortable field',
        required: true

      argument :order,
        @@order_enum,
        description: 'Sort order',
        required: true
    end
  end
end
# rubocop:enable Style/ClassVars
