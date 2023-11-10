module GraphqlQuery
  module Constants
    RESERVED_FIELDS = %i[
      limit
      offset
      sort_by
      filter_by
      search_by
    ].freeze

    FILTERS = {
      eq: {
        statement: proc { |results, key, value| results.where({ key => value }) },
        description: 'Equal',
        transform_type: proc { |type| type }
      },
      neq: {
        statement: proc { |results, key, value| results.where.not({ key => value }) },
        description: 'Not equal',
        transform_type: proc { |type| type }
      },
      in: {
        statement: proc { |results, key, value| results.where({ key => value }) },
        description: 'In',
        transform_type: proc { |type| [type] }
      },
      nin: {
        statement: proc { |results, key, value| results.where.not({ key => value }) },
        description: 'Not in',
        transform_type: proc { |type| [type] }
      },
      gt: {
        statement: proc { |results, key, value| results.where("#{key} > ?", value) },
        description: 'Greater than',
        transform_type: proc { |type| type }
      },
      gte: {
        statement: proc { |results, key, value| results.where("#{key} >= ?", value) },
        description: 'Greater than or equal to',
        transform_type: proc { |type| type }
      },
      lt: {
        statement: proc { |results, key, value| results.where("#{key} < ?", value) },
        description: 'Lower than',
        transform_type: proc { |type| type }
      },
      lte: {
        statement: proc { |results, key, value| results.where("#{key} <= ?", value) },
        description: 'Lower than or equal to',
        transform_type: proc { |type| type }
      }
    }.freeze
  end
end
