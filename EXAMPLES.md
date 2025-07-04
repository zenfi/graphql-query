# GraphQL Query Examples

This document provides comprehensive examples of how to use the `graphql_query` gem in various scenarios.

## Table of Contents

- [Basic Setup](#basic-setup)
- [Simple Filter Example](#simple-filter-example)
- [Advanced Filtering](#advanced-filtering)
- [Sorting Examples](#sorting-examples)
- [Search Examples](#search-examples)
- [Complete Real-World Example](#complete-real-world-example)
- [Performance Optimization](#performance-optimization)
- [Testing Examples](#testing-examples)

## Basic Setup

### 1. Initializer Configuration

```ruby
# config/initializers/graphql_query.rb
require 'graphql'
require 'graphql_query'

# Configure the enum class for sorting
GraphqlQuery::Sorter.enum_class = GraphQL::Schema::Enum
```

### 2. Basic Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :posts
  has_one :profile
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
```

## Simple Filter Example

### 1. Create Filter Types

```ruby
# app/graphql/types/filters/string_filter.rb
module Types
  module Filters
    class StringFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'StringFilter'
      description 'Filter operations for string fields'
      
      include_filter_arguments(GraphQL::Types::String, %i[eq neq in nin])
    end
  end
end
```

### 2. Create Filter Input

```ruby
# app/graphql/types/users/filter_input.rb
module Types
  module Users
    class FilterInput < Types::Base::InputObject
      graphql_name 'UsersFilterInput'
      description 'Filter criteria for users'
      
      argument :name, Types::Filters::StringFilter, required: false
      argument :email, Types::Filters::StringFilter, required: false
    end
  end
end
```

### 3. Use in Query

```ruby
# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::Base::Object
    field :users, [Types::UserType], null: false do
      argument :filter_by, Types::Users::FilterInput, required: false
    end
    
    def users(filter_by: nil)
      query = User.all
      GraphqlQuery::Main.new(query, { filter_by: filter_by }).to_relation
    end
  end
end
```

### 4. GraphQL Query

```graphql
query {
  users(filterBy: { name: { eq: "John" } }) {
    id
    name
    email
  }
}
```

## Advanced Filtering

### 1. Multiple Filter Types

```ruby
# app/graphql/types/filters/id_filter.rb
module Types
  module Filters
    class IdFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'IDFilter'
      include_filter_arguments(GraphQL::Types::ID, %i[eq neq in nin])
    end
  end
end

# app/graphql/types/filters/int_filter.rb
module Types
  module Filters
    class IntFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'IntFilter'
      include_filter_arguments(GraphQL::Types::Int, %i[eq neq in nin gt gte lt lte])
    end
  end
end

# app/graphql/types/filters/boolean_filter.rb
module Types
  module Filters
    class BooleanFilter < Types::Base::InputObject
      extend GraphqlQuery::Filter
      
      graphql_name 'BooleanFilter'
      include_filter_arguments(GraphQL::Types::Boolean, %i[eq neq])
    end
  end
end
```

### 2. Advanced Filter Input

```ruby
# app/graphql/types/users/advanced_filter_input.rb
module Types
  module Users
    class AdvancedFilterInput < Types::Base::InputObject
      graphql_name 'UsersAdvancedFilterInput'
      description 'Advanced filter criteria for users'
      
      argument :id, Types::Filters::IdFilter, required: false
      argument :name, Types::Filters::StringFilter, required: false
      argument :email, Types::Filters::StringFilter, required: false
      argument :age, Types::Filters::IntFilter, required: false
      argument :active, Types::Filters::BooleanFilter, required: false
      argument :created_at, Types::Filters::DateTimeFilter, required: false
    end
  end
end
```

### 3. Complex GraphQL Query

```graphql
query {
  users(
    filterBy: {
      age: { gte: 18, lte: 65 }
      active: { eq: true }
      name: { nin: ["admin", "test"] }
      email: { in: ["@gmail.com", "@outlook.com"] }
    }
  ) {
    id
    name
    email
    age
    active
  }
}
```

## Sorting Examples

### 1. Basic Sorting

```ruby
# app/graphql/types/users/sort_input.rb
module Types
  module Users
    class SortInput < Types::Base::InputObject
      extend GraphqlQuery::Sorter
      
      graphql_name 'UsersSortInput'
      description 'Sort options for users'
      
      include_sort_arguments('User', %i[name email createdAt updatedAt age random])
    end
  end
end
```

### 2. Multi-field Sorting Query

```graphql
query {
  users(
    sortBy: [
      { field: "name", order: ASC }
      { field: "createdAt", order: DESC }
      { field: "age", order: ASC }
    ]
  ) {
    id
    name
    email
    age
    createdAt
  }
}
```

### 3. Random Sorting

```graphql
query {
  users(sortBy: [{ field: "random", order: ASC }]) {
    id
    name
    email
  }
}
```

## Search Examples

### 1. Search Input

```ruby
# app/graphql/types/users/search_input.rb
module Types
  module Users
    class SearchInput < Types::Base::InputObject
      graphql_name 'UsersSearchInput'
      description 'Search criteria for users'
      
      argument :name, GraphQL::Types::String, 
               description: 'Search by name (case-insensitive)',
               required: false
               
      argument :email, GraphQL::Types::String,
               description: 'Search by email (case-insensitive)',
               required: false
               
      argument :bio, GraphQL::Types::String,
               description: 'Search by bio (case-insensitive)',
               required: false
    end
  end
end
```

### 2. Search Query

```graphql
query {
  users(
    searchBy: {
      name: "john"
      email: "gmail"
    }
  ) {
    id
    name
    email
  }
}
```

## Complete Real-World Example

### 1. Blog Post Model

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  
  validates :title, presence: true
  validates :content, presence: true
  
  scope :published, -> { where(published: true) }
  scope :recent, -> { where('created_at >= ?', 1.week.ago) }
end
```

### 2. Complete Filter Types

```ruby
# app/graphql/types/posts/filter_input.rb
module Types
  module Posts
    class FilterInput < Types::Base::InputObject
      graphql_name 'PostsFilterInput'
      description 'Filter criteria for posts'
      
      argument :id, Types::Filters::IdFilter, required: false
      argument :title, Types::Filters::StringFilter, required: false
      argument :published, Types::Filters::BooleanFilter, required: false
      argument :user_id, Types::Filters::IdFilter, required: false
      argument :created_at, Types::Filters::DateTimeFilter, required: false
      argument :view_count, Types::Filters::IntFilter, required: false
    end
  end
end

# app/graphql/types/posts/sort_input.rb
module Types
  module Posts
    class SortInput < Types::Base::InputObject
      extend GraphqlQuery::Sorter
      
      graphql_name 'PostsSortInput'
      include_sort_arguments('Post', %i[title createdAt updatedAt viewCount random])
    end
  end
end

# app/graphql/types/posts/search_input.rb
module Types
  module Posts
    class SearchInput < Types::Base::InputObject
      graphql_name 'PostsSearchInput'
      description 'Search criteria for posts'
      
      argument :title, GraphQL::Types::String, required: false
      argument :content, GraphQL::Types::String, required: false
      argument :tags, GraphQL::Types::String, required: false
    end
  end
end
```

### 3. Complete Query Implementation

```ruby
# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::Base::Object
    field :posts, PostType.connection_type, null: false do
      description 'Fetch posts with advanced filtering, sorting, and searching'
      
      argument :filter_by, Types::Posts::FilterInput, required: false
      argument :search_by, Types::Posts::SearchInput, required: false
      argument :sort_by, [Types::Posts::SortInput], required: false
      argument :published_only, GraphQL::Types::Boolean, required: false
    end
    
    def posts(filter_by: nil, search_by: nil, sort_by: nil, published_only: false)
      # Start with base query
      base_query = Post.includes(:user, :comments)
      
      # Apply published filter if requested
      base_query = base_query.published if published_only
      
      # Apply GraphQL Query processing
      GraphqlQuery::Main.new(
        base_query,
        {
          filter_by: filter_by,
          search_by: search_by,
          sort_by: sort_by
        }
      ).to_relation
    end
  end
end
```

### 4. Complex Query Example

```graphql
query GetPosts {
  posts(
    publishedOnly: true
    filterBy: {
      viewCount: { gte: 100 }
      createdAt: { gte: "2024-01-01" }
      userId: { in: ["1", "2", "3"] }
    }
    searchBy: {
      title: "GraphQL"
      content: "tutorial"
    }
    sortBy: [
      { field: "viewCount", order: DESC }
      { field: "createdAt", order: DESC }
    ]
  ) {
    edges {
      node {
        id
        title
        content
        viewCount
        createdAt
        user {
          id
          name
        }
        comments {
          id
          content
        }
      }
    }
  }
}
```

## Performance Optimization

### 1. Database Indexes

```ruby
# db/migrate/xxx_add_indexes_for_graphql_queries.rb
class AddIndexesForGraphqlQueries < ActiveRecord::Migration[7.0]
  def change
    # Single column indexes
    add_index :posts, :published
    add_index :posts, :view_count
    add_index :posts, :created_at
    add_index :posts, :user_id
    
    # Composite indexes for common filter combinations
    add_index :posts, [:published, :created_at]
    add_index :posts, [:user_id, :published]
    add_index :posts, [:view_count, :created_at]
    
    # Indexes for search fields
    add_index :posts, :title
    add_index :posts, :content # Consider using database-specific full-text search
  end
end
```

### 2. Optimized Query with Includes

```ruby
def posts(**args)
  # Use includes to prevent N+1 queries
  base_query = Post
    .includes(:user, :comments, :tags)
    .joins(:user) # Inner join if you need to filter by user fields
  
  # Apply custom scopes before GraphQL processing
  base_query = base_query.published if args[:published_only]
  
  GraphqlQuery::Main.new(base_query, args).to_relation
end
```

### 3. Query Complexity Control

```ruby
# app/graphql/types/query_type.rb
field :posts, PostType.connection_type, null: false, max_page_size: 100 do
  # Limit complexity to prevent expensive queries
  complexity -> (ctx, args, child_complexity) do
    base_complexity = child_complexity * (args[:first] || args[:last] || 10)
    
    # Add complexity for filters
    filter_complexity = args[:filter_by]&.keys&.size || 0
    search_complexity = args[:search_by]&.keys&.size || 0
    
    base_complexity + filter_complexity + search_complexity
  end
end
```

## Testing Examples

### 1. RSpec Tests

```ruby
# spec/graphql/queries/posts_query_spec.rb
RSpec.describe 'Posts Query', type: :request do
  let(:user) { create(:user) }
  let!(:published_post) { create(:post, user: user, published: true, view_count: 150) }
  let!(:draft_post) { create(:post, user: user, published: false, view_count: 50) }
  
  describe 'filtering' do
    it 'filters by published status' do
      query = <<~GRAPHQL
        query {
          posts(filterBy: { published: { eq: true } }) {
            edges { node { id title published } }
          }
        }
      GRAPHQL
      
      post '/graphql', params: { query: query }
      
      data = JSON.parse(response.body)['data']
      expect(data['posts']['edges'].size).to eq(1)
      expect(data['posts']['edges'][0]['node']['id']).to eq(published_post.id.to_s)
    end
    
    it 'filters by view count range' do
      query = <<~GRAPHQL
        query {
          posts(filterBy: { viewCount: { gte: 100 } }) {
            edges { node { id viewCount } }
          }
        }
      GRAPHQL
      
      post '/graphql', params: { query: query }
      
      data = JSON.parse(response.body)['data']
      expect(data['posts']['edges'].size).to eq(1)
      expect(data['posts']['edges'][0]['node']['viewCount']).to eq(150)
    end
  end
  
  describe 'sorting' do
    it 'sorts by view count descending' do
      query = <<~GRAPHQL
        query {
          posts(sortBy: [{ field: "viewCount", order: DESC }]) {
            edges { node { id viewCount } }
          }
        }
      GRAPHQL
      
      post '/graphql', params: { query: query }
      
      data = JSON.parse(response.body)['data']
      view_counts = data['posts']['edges'].map { |edge| edge['node']['viewCount'] }
      expect(view_counts).to eq([150, 50])
    end
  end
  
  describe 'searching' do
    let!(:graphql_post) { create(:post, title: 'GraphQL Tutorial', content: 'Learn GraphQL') }
    
    it 'searches by title' do
      query = <<~GRAPHQL
        query {
          posts(searchBy: { title: "GraphQL" }) {
            edges { node { id title } }
          }
        }
      GRAPHQL
      
      post '/graphql', params: { query: query }
      
      data = JSON.parse(response.body)['data']
      expect(data['posts']['edges'].size).to eq(1)
      expect(data['posts']['edges'][0]['node']['title']).to eq('GraphQL Tutorial')
    end
  end
end
```

### 2. Factory Bot Setup

```ruby
# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    published { false }
    view_count { rand(1..1000) }
    user
    
    trait :published do
      published { true }
    end
    
    trait :popular do
      view_count { rand(500..2000) }
    end
  end
end
```

This comprehensive example demonstrates the full power of the `graphql_query` gem with real-world scenarios, performance considerations, and testing approaches.