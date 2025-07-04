# frozen_string_literal: true

require_relative 'lib/graphql_query/version'

Gem::Specification.new do |spec|
  spec.name     = 'graphql_query'
  spec.version  = GraphqlQuery::VERSION
  spec.authors  = ['Ernesto García', 'Manuel de la Torre']
  spec.summary  = 'Helper to convert GraphQL into robust ActiveRecord queries'
  spec.homepage = 'https://github.com/zenfi/graphql-query'
  spec.required_ruby_version = '>= 3.1'
  spec.license = 'MIT'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/zenfi/graphql-query',
    # 'changelog_uri' => 'https://github.com/zenfi/graphql-query/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/zenfi/graphql-query/issues',
    'documentation_uri' => 'https://github.com/zenfi/graphql-query/blob/main/README.md'
  }

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE']
  spec.require_paths = ['lib']
end
