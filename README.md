# GraphQL Query

![Tests](https://github.com/zenfi/graphql-query/workflows/Tests/badge.svg)
![Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.7.6-blue)
![License](https://img.shields.io/github/license/zenfi/graphql-query?color=blue)

A Ruby gem that converts GraphQL queries into robust ActiveRecord queries with advanced filtering, sorting, and searching capabilities.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Features](#features)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Filters](#filters)
  - [Sorters](#sorters)
  - [Searchers](#searchers)
  - [Complete Example](#complete-example)
- [API Reference](#api-reference)
- [Advanced Usage](#advanced-usage)
- [Performance Considerations](#performance-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Installation

**Prerequisites:**
- Ruby >= 2.7.6
- Rails with ActiveRecord
- GraphQL Ruby gem

Add the gem to your project:

```bash
gem install graphql_query

# Or add to your Gemfile
gem 'graphql_query'
```

Then run:

```bash
bundle install
```

## Quick Start

1. **Configure the gem** in an initializer (`config/initializers/graphql_query.rb`):

```ruby
require 'graphql'
require 'graphql_query'

GraphqlQuery::Sorter.enum_class = GraphQL::Schema::Enum
```

2. **Create a simple filter**:

```ruby
class UserFilter < Types::Base::InputObject
  extend GraphqlQuery::Filter
  
  graphql_name 'UserFilter'
  include_filter_arguments(GraphQL::Types::ID, %i[eq neq in nin])
end
```

3. **Use it in a resolver**:

```ruby
def users(**args)
  query = User.all
  GraphqlQuery::Main.new(query, args).to_relation
end
```

## Features

- **🔍 Advanced Filtering**: Support for 8 different filter operators
- **📊 Flexible Sorting**: Multi-field sorting with custom order
- **🔎 Text Search**: Full-text search across multiple fields
- **⚡ Performance**: Generates efficient ActiveRecord queries
- **🛡️ Security**: SQL injection protection built-in
- **🔧 Extensible**: Easy to customize and extend

## Configuration

Create an initializer file to configure the gem:

```ruby
# config/initializers/graphql_query.rb
require 'graphql'
require 'graphql_query'

# Set the GraphQL Schema Enum class for sorting
GraphqlQuery::Sorter.enum_class = GraphQL::Schema::Enum
```

## Usage

### Filters

Create filters by extending the `GraphqlQuery::Filter` class and calling `include_filter_arguments`:

#### Available Filter Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equal | `{ id: { eq: "123" } }` |
| `neq` | Not equal | `{ status: { neq: "inactive" } }` |
| `in` | In a list | `{ category: { in: ["tech", "science"] } }` |
| `nin` | Not in a list | `{ priority: { nin: ["low", "medium"] } }` |
| `gt` | Greater than | `{ age: { gt: 18 } }` |
| `gte` | Greater than or equal | `{ score: { gte: 85 } }` |
| `lt` | Less than | `{ price: { lt: 100 } }` |
| `lte` | Less than or equal | `{ quantity: { lte: 50 } }` |

#### Filter Examples

**Basic ID Filter:**
```ruby
module Types
  module Filters
    class IdFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'IDFilter'
      description 'Filter commands for ID fields'
      
      include_filter_arguments(GraphQL::Types::ID, %i[eq neq in nin])
    end
  end
end
```

**String Filter:**
```ruby
module Types
  module Filters
    class StringFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'StringFilter'
      description 'Filter commands for string fields'
      
      include_filter_arguments(GraphQL::Types::String, %i[eq neq in nin])
    end
  end
end
```

**Numeric Filter:**
```ruby
module Types
  module Filters
    class IntFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'IntFilter'
      description 'Filter commands for integer fields'
      
      include_filter_arguments(GraphQL::Types::Int, %i[eq neq in nin gt gte lt lte])
    end
  end
end
```

**Combined Filter Input:**
```ruby
module Types
  module Users
    class FilterInput < Types::Base::InputObject
      graphql_name 'UsersFilterInput'
      description 'Filter criteria for users'
      
      argument :id, Types::Filters::IdFilter, required: false
      argument :name, Types::Filters::StringFilter, required: false
      argument :age, Types::Filters::IntFilter, required: false
      argument :status, Types::Filters::StringFilter, required: false
    end
  end
end
```

### Sorters

Create sorters by extending the `GraphqlQuery::Sorter` class:

```ruby
module Types
  module Users
    class SortInput < Types::Base::InputObject
      extend GraphqlQuery::Sorter
      
      graphql_name 'UsersSortInput'
      description 'Sort criteria for users'
      
      # Model name and sortable fields (in camelCase)
      include_sort_arguments('User', %i[name email createdAt updatedAt random])
    end
  end
end
```

#### Special Sort Fields

- **`random`**: Provides random ordering using `RANDOM()` function
- **camelCase fields**: Automatically converted to snake_case (e.g., `createdAt` → `created_at`)

### Searchers

Create search inputs for text-based searching:

```ruby
module Types
  module Users
    class SearchInput < Types::Base::InputObject
      graphql_name 'UsersSearchInput'
      description 'Search criteria for users'
      
      argument :name, GraphQL::Types::String, 
               description: 'Search users by name',
               required: false
               
      argument :email, GraphQL::Types::String,
               description: 'Search users by email',
               required: false
               
      argument :bio, GraphQL::Types::String,
               description: 'Search users by bio',
               required: false
    end
  end
end
```

### Complete Example

**GraphQL Field Definition:**
```ruby
module Types
  class QueryType < Types::Base::Object
    field :users, UserType.connection_type, null: false do
      description 'Fetch users with advanced filtering, sorting, and searching'
      
      argument :filter_by, Types::Users::FilterInput, required: false
      argument :search_by, Types::Users::SearchInput, required: false
      argument :sort_by, [Types::Users::SortInput], required: false
    end
  end
end
```

**Resolver Implementation:**
```ruby
module Resolvers
  class UsersResolver < GraphQL::Schema::Resolver
    def users(**args)
      # Start with your base query
      base_query = User.includes(:posts, :comments)
      
      # Apply GraphQL Query processing
      GraphqlQuery::Main.new(base_query, args).to_relation
    end
  end
end
```

**GraphQL Query Example:**
```graphql
query GetUsers {
  users(
    filterBy: {
      age: { gte: 18, lte: 65 }
      status: { in: ["active", "premium"] }
      name: { neq: "admin" }
    }
    searchBy: {
      name: "john"
      email: "gmail"
    }
    sortBy: [
      { field: "name", order: ASC }
      { field: "createdAt", order: DESC }
    ]
  ) {
    edges {
      node {
        id
        name
        email
        age
        status
      }
    }
  }
}
```

This query will:
- Filter users aged 18-65 with active/premium status, excluding admin
- Search for "john" in name field and "gmail" in email field
- Sort by name (ascending) then by creation date (descending)

## API Reference

### GraphqlQuery::Main

The main class that processes GraphQL arguments and generates ActiveRecord queries.

#### Constructor

```ruby
GraphqlQuery::Main.new(relation, args)
```

- `relation`: ActiveRecord relation or model class
- `args`: Hash of GraphQL arguments (typically from resolver)

#### Methods

- `#to_relation`: Returns the processed ActiveRecord relation

### GraphqlQuery::Filter

Module for creating filter input types.

#### Methods

- `include_filter_arguments(type, operators)`: Adds filter arguments to GraphQL input type
  - `type`: GraphQL type (e.g., `GraphQL::Types::String`)
  - `operators`: Array of operator symbols (e.g., `%i[eq neq in nin]`)

### GraphqlQuery::Sorter

Module for creating sort input types.

#### Class Methods

- `enum_class=`: Set the GraphQL enum class to use
- `enum_class`: Get the current GraphQL enum class

#### Instance Methods

- `include_sort_arguments(model_name, fields)`: Adds sort arguments to GraphQL input type
  - `model_name`: String name of the model
  - `fields`: Array of sortable field names (camelCase)

## Advanced Usage

### Custom Base Queries

You can start with complex base queries:

```ruby
def users(**args)
  base_query = User
    .joins(:profile)
    .includes(:posts)
    .where(active: true)
    .where('profiles.verified = ?', true)
  
  GraphqlQuery::Main.new(base_query, args).to_relation
end
```

### Combining with Pagination

Works seamlessly with connection-based pagination:

```ruby
field :users, UserType.connection_type, null: false, max_page_size: 100
```

### Security Considerations

The gem automatically handles SQL injection protection, but consider:

- Validate input sizes to prevent DoS attacks
- Use reasonable limits on array inputs
- Monitor query complexity and execution time

## Performance Considerations

### Database Indexes

Ensure proper database indexes for filtered and sorted fields:

```ruby
# Migration example
class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :age
    add_index :users, :status
    add_index :users, [:name, :created_at]
  end
end
```

### Query Optimization

- Use `includes` or `joins` for associated data
- Consider using `select` to limit returned columns
- Monitor query execution plans

### Memory Usage

- Set reasonable connection limits
- Use pagination for large datasets
- Consider implementing query complexity analysis

## Troubleshooting

### Common Issues

**1. "Filter X does not exist" Error**
```ruby
# Make sure the operator is supported
include_filter_arguments(GraphQL::Types::String, %i[eq neq]) # ✓ Valid
include_filter_arguments(GraphQL::Types::String, %i[contains]) # ✗ Invalid
```

**2. "enum_class not set" Error**
```ruby
# Add to your initializer
GraphqlQuery::Sorter.enum_class = GraphQL::Schema::Enum
```

**3. Field Not Found in Database**
```ruby
# Ensure field names match your database columns
# camelCase is automatically converted to snake_case
include_sort_arguments('User', %i[createdAt]) # → created_at
```

**4. Search Not Working**
```ruby
# Search uses ILIKE, ensure your database supports it
# For case-sensitive databases, consider adding LOWER() functions
```

### Debugging

Enable query logging to see generated SQL:

```ruby
# In Rails console or test
ActiveRecord::Base.logger = Logger.new(STDOUT)
```

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`bundle exec rspec`)
6. Run the linter (`bundle exec rubocop`)
7. Commit your changes (`git commit -am 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

### Development Setup

```bash
git clone https://github.com/zenfi/graphql-query.git
cd graphql-query
bundle install
bundle exec rspec
```

## License

This gem is available as open source under the terms of the [MIT License](LICENSE).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

---

**Questions?** Open an issue on [GitHub](https://github.com/zenfi/graphql-query/issues) or start a discussion.
