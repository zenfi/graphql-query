# GraphQL Query

![Tests](https://github.com/zenfi/graphql-query/workflows/Tests/badge.svg)
![Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.7.6-blue)
![License](https://img.shields.io/github/license/zenfi/graphql-query?color=blue)

Ruby Gem to convert GraphQL into robust ActiveRecord queries.

## Install

1. Add the gem to your project:

```sh
gem install graphql_query

# Or using bundler
bundle add graphql_query
```

2. Create an initializer file (`initializers/graphql_query.rb`) that requires the gem and sets the class to be used as Enum:

```rb
require 'graphql'
require 'graphql_query'

GraphQLQuery::Sorter.enum_class = GraphQL::Schema::Enum
```

## Filters

Create filters by extending the `GraphqlQuery::Filter` class and calling `include_filter_arguments` with the arguments:

| Argument | Type | Description |
| -------- | ---- | ----------- |
|`type`|`Class`|The GraphQL type that is going to be used in the filter.|
|`operator`|`[Symbol]`|The list of commands that will support the filter.|

Valid operators are:

* `eq`: equal
* `neq`: not equal
* `in`: in a list
* `nin`: not in a list
* `gt`: greater than
* `gte`: equal or greater than
* `lt`: lower than
* `lte`: equal or lower than

**Example:**

```rb
module Types
  module Filters
    class IdType < Types::Base::InputObject
      extend GraphqlQuery::Filter

      graphql_name 'IDFilter'

      description 'Filter commands for ID fields'

      include_filter_arguments(ID, %i[eq neq in nin])
    end
  end
end
```

Then create an input type that accepts all the fields you want as filters.

```rb
module Types
  module Pets
    class FilterInputType < Types::Base::InputObject
      graphql_name 'PetsFilterInput'

      argument :id,
        Types::Filters::IdType,
        description: 'Filter specification to fetch pets by ID',
        required: false

      argument :color,
        Types::Filters::ColorType,
        description: 'Filter specification to fetch pets by color',
        required: false
    end
  end
end

```

## Sorters

Create sorters by extending the `GraphqlQuery::Sorter` class and calling `include_sort_arguments` with the arguments:

| Argument | Type | Description |
| -------- | ---- | ----------- |
|`model_name`|`String`|The name of the type that will implement this sorting input.|
|`fields`|`[Symbol]`|The list of fields in the type that can be used for sorting. In **camelCase**.|

```rb
module Types
  module Pets
    class SortInputType < Types::Base::InputObject
      extend GraphqlQuery::Sorter

      graphql_name 'PetsSortInput'

      include_order_arguments('Pets', %i[name random createdAt])
    end
  end
end
```

## Searchers

To search by a string, create an input type that accepts all the fields you want.

```rb
module Types
  module Pets
    class SearchInputType < Types::Base::InputObject
      graphql_name 'PetsSearchInput'

      description 'Search criteria to fetch pets'

      argument :name,
        String,
        description: 'Filters pets matching a name',
        required: false

      argument :description,
        String,
        description: 'Filters pets matching a description',
        required: false
    end
  end
end
```

## Usage

After declaring the filters, sorters and searchers, you can use them in your queries by using a `connection_type` and setting them as arguments:

```rb
field :pets,
  PetType.connection_type,
  description: 'Returns a list of pets given a set of conditions',
  null: false do
    argument :filter_by, Types::Pets::FilterInputType, required: false
    argument :search_by, Types::Pets::SearchInputType, required: false
    argument :filter_by, [Types::Pets::SortInputType], required: false
  end
```

Then create a resolver that finds the records using the `GraphqlQuery::Main` class:

```rb
def pets(**args)
  query = ::Pets.where(owner_id: authenticated_user.id)
  GraphqlQuery::Main.new(query, args).to_relation
end
```

This will create a query that will allow clients to perform advanced queries like:

```graphql
query {
  pets(
    filterBy: {
      id: {
        in: ["1", "2", ... "N"]
      }
    },
    searchBy: {
      description: "friendly"
    },
    sortBy: [
      { field: "name", order: ASC },
      { field: "random", order: DESC }
    ]
  )
}
```

Which finds pets:
* with an ID in a list
* containing the word "friendly" in the description
* sorted by name ascending and then by a random order

## License

MIT
