require 'active_support'
require 'active_support/time'

module GraphqlQuery
  module Constants
    RESERVED_FIELDS = %i[
      limit
      offset
      sort_by
      filter_by
      search_by
    ].freeze

    # A bare Date compared against a timestamp column resolves to midnight in the
    # database's time zone, so `lte: 2026-07-29` silently drops everything that
    # happened during the 29th. In an application whose time zone is not UTC the
    # boundary also lands mid-day: with `Time.zone = 'Mexico City'`, that filter
    # cuts off at 18:00 on the 28th.
    #
    # So expand a Date to the edges of its day in the application's time zone.
    # Values that already carry a time pass through untouched.
    module DayBounds
      class << self
        def start_of(value)
          plain_date?(value) ? value.in_time_zone.beginning_of_day : value
        end

        def end_of(value)
          plain_date?(value) ? value.in_time_zone.end_of_day : value
        end

        private

        # DateTime subclasses Date, so an is_a?(Date) check on its own would also
        # swallow values that were given an explicit time.
        def plain_date?(value)
          value.is_a?(Date) && !value.is_a?(DateTime)
        end
      end
    end

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
        statement: proc { |results, key, value| results.where("#{key} > ?", DayBounds.end_of(value)) },
        description: 'Greater than',
        transform_type: proc { |type| type }
      },
      gte: {
        statement: proc { |results, key, value| results.where("#{key} >= ?", DayBounds.start_of(value)) },
        description: 'Greater than or equal to',
        transform_type: proc { |type| type }
      },
      lt: {
        statement: proc { |results, key, value| results.where("#{key} < ?", DayBounds.start_of(value)) },
        description: 'Lower than',
        transform_type: proc { |type| type }
      },
      lte: {
        statement: proc { |results, key, value| results.where("#{key} <= ?", DayBounds.end_of(value)) },
        description: 'Lower than or equal to',
        transform_type: proc { |type| type }
      }
    }.freeze
  end
end
