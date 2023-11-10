# frozen_string_literal: true

require_relative 'lib/graphql_query/version'

Gem::Specification.new do |spec|
  spec.name     = 'graphql_query'
  spec.version  = GraphqlQuery::VERSION
  spec.authors  = ['Ernesto García', 'Manuel de la Torre']
  spec.summary  = 'Helper to convert GraphQL into robust ActiveRecord queries'
  spec.homepage = 'https://github.com/zenfi/graphql-query'
  spec.required_ruby_version = '>= 2.7.6'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/zenfi/graphql-query',
    'changelog_uri' => 'https://github.com/zenfi/graphql-query/CHANGELOG.md'
  }

  spec.files = Dir['lib/**/*']
end
