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

  # A Date carries no time of day, so comparing it against a timestamp column
  # resolved to midnight in the database's time zone: `lte: 2026-07-29` cut off
  # before the 29th had even started locally. The range operators expand a Date
  # to the edges of its day in the application's time zone instead.
  describe 'a Date value' do
    subject(:bound) do
      filters[operator][:statement].call(results, key, value)
      captured_args.last
    end

    let(:results) { double }
    let(:captured_args) { [] }
    let(:value) { Date.new(2026, 7, 29) }

    around do |example|
      original_zone = Time.zone
      Time.zone = 'America/Mexico_City'
      example.run
      Time.zone = original_zone
    end

    before do
      allow(results).to receive(:where) do |*args|
        captured_args.concat(args)
        results
      end
    end

    describe :gte do
      let(:operator) { :gte }

      it 'opens the range at midnight, local time' do
        expect(bound.strftime('%F %T %Z')).to eq('2026-07-29 00:00:00 CST')
      end
    end

    describe :lte do
      let(:operator) { :lte }

      it 'closes the range at the end of the day, local time' do
        expect(bound.strftime('%F %T %Z')).to eq('2026-07-29 23:59:59 CST')
      end
    end

    describe :gt do
      let(:operator) { :gt }

      it 'excludes the whole day, not just its first instant' do
        expect(bound.strftime('%F %T %Z')).to eq('2026-07-29 23:59:59 CST')
      end
    end

    describe :lt do
      let(:operator) { :lt }

      it 'excludes the whole day, not just its last instant' do
        expect(bound.strftime('%F %T %Z')).to eq('2026-07-29 00:00:00 CST')
      end
    end

    context 'when the value already carries a time' do
      let(:operator) { :lte }
      let(:value) { Time.zone.parse('2026-07-29 09:30:00') }

      it 'is left untouched' do
        expect(bound).to eq(value)
      end
    end
  end
end
