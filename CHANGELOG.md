# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation with examples and troubleshooting guide
- API reference section
- Performance considerations documentation
- Contributing guidelines
- Table of contents for better navigation

### Changed
- Improved README structure and clarity
- Enhanced code examples with more realistic scenarios
- Better organization of documentation sections

## [1.0.1] - 2024-01-XX

### Fixed
- Various bug fixes and improvements

## [1.0.0] - 2024-01-XX

### Added
- Initial release of graphql_query gem
- Filter functionality with 8 operators (eq, neq, in, nin, gt, gte, lt, lte)
- Sorting functionality with ASC/DESC ordering
- Search functionality using ILIKE pattern matching
- Support for random ordering
- Automatic camelCase to snake_case conversion for field names
- SQL injection protection
- ActiveRecord query generation from GraphQL arguments

### Features
- `GraphqlQuery::Filter` module for creating filter input types
- `GraphqlQuery::Sorter` module for creating sort input types
- `GraphqlQuery::Main` class for processing GraphQL arguments
- Support for complex base queries
- Integration with GraphQL connection types
- Configurable enum class for sorting

### Security
- Built-in SQL injection protection
- Safe parameter binding for all database operations

---

## Version History

- **1.0.1**: Current stable release with bug fixes
- **1.0.0**: Initial release with core functionality

## Migration Guide

### From 0.x to 1.0

This is the initial stable release. No migration required.

## Support

For questions and support:
- [GitHub Issues](https://github.com/zenfi/graphql-query/issues)
- [GitHub Discussions](https://github.com/zenfi/graphql-query/discussions)

## Contributing

See [Contributing Guidelines](README.md#contributing) for information on how to contribute to this project.