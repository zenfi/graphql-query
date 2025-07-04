require 'spec_helper'
require 'graphql_query/constants'

shared_examples_for 'a GraphQL filter' do
  let(:filter) { filters[subject] }
  let(:results) { double }
  let(:apply) { filter[:statement].call(results, key, value) }

  before do
    allow(results).to receive_messages(where: results, not: results)
  end

  it 'calls expected statement' do
    apply
    calls.each do |call|
      expect(results).to have_received(call[:method]).with(*call[:args])
    end
  end

  it 'transform type returns type' do
    expect(filter[:transform_type].call(type)).to eq(expected_type)
  end
end

describe 'FILTERS' do
  let(:filters) { GraphqlQuery::Constants::FILTERS }
  let(:table) { 'table_name' }
  let(:key) { 'key' }
  let(:type) { double }

  describe :eq do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { 'some-value' }
      let(:calls) do
        [
          {
            method: :where,
            args: [
              {
                key => value
              }
            ]
          }
        ]
      end
      let(:expected_type) { type }
    end
  end

  describe :neq do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { 'some-value' }
      let(:calls) do
        [
          {
            method: :where,
            args: [no_args]
          },
          {
            method: :not,
            args: [
              {
                key => value
              }
            ]
          }
        ]
      end
      let(:expected_type) { type }
    end
  end

  describe :in do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { %w[some-value-1 some-value-2] }
      let(:calls) do
        [
          {
            method: :where,
            args: [
              {
                key => value
              }
            ]
          }
        ]
      end
      let(:expected_type) { [type] }
    end
  end

  describe :nin do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { %w[some-value-1 some-value-2] }
      let(:calls) do
        [
          {
            method: :where,
            args: [no_args]
          },
          {
            method: :not,
            args: [
              {
                key => value
              }
            ]
          }
        ]
      end
      let(:expected_type) { [type] }
    end
  end

  describe :gt do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { 10 }
      let(:calls) do
        [
          {
            method: :where,
            args: [
              "#{key} > ?",
              value
            ]
          }
        ]
      end
      let(:expected_type) { type }
    end
  end

  describe :gte do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { 10 }
      let(:calls) do
        [
          {
            method: :where,
            args: [
              "#{key} >= ?",
              value
            ]
          }
        ]
      end
      let(:expected_type) { type }
    end
  end

  describe :lt do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { 10 }
      let(:calls) do
        [
          {
            method: :where,
            args: [
              "#{key} < ?",
              value
            ]
          }
        ]
      end
      let(:expected_type) { type }
    end
  end

  describe :lte do
    it_behaves_like 'a GraphQL filter' do
      let(:value) { 10 }
      let(:calls) do
        [
          {
            method: :where,
            args: [
              "#{key} <= ?",
              value
            ]
          }
        ]
      end
      let(:expected_type) { type }
    end
  end
end
