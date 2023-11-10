require 'spec_helper'
require 'graphql_query/main'

shared_examples_for 'a call to filtered_model' do
  context 'with no filters' do
    let(:filter_by) { nil }
    let(:search) { nil }

    it 'calls the default where clause once' do
      expect(model).to have_received(:where).with(nil).once
    end
  end

  context 'with filters' do
    it 'calls where for each filter' do
      filter_by.each do |field, key_filters|
        key_filters.each do |filter, value|
          key = "#{table_name}.#{field}"
          expect(GraphqlQuery::Constants::FILTERS[filter][:statement])
            .to have_received(:call)
            .with(model, key, value)
        end
      end
    end
  end

  context 'with query' do
    it 'calls where and or with passed arguments' do
      expect(model).to have_received(:and).once
      expect(model).to have_received(:or).exactly(search.size - 1).times

      search.each do |field, value|
        expect(model).to have_received(:where).with("#{model.table_name}.#{field} ILIKE ?", "%#{value}%")
      end
    end
  end
end

shared_examples_for 'a call to sorted_model' do
  context 'with sorter' do
    it 'calls order for specified field with order' do
      expect(model).to have_received(:order)
        .with("#{args[:sort_by][:field]} #{args[:sort_by][:order]}")
    end
  end

  context 'when sort field is camel cased' do
    let(:sorter) { { field: 'createdAt', order: 'ASC' } }

    it 'converts the field to underscore' do
      expect(model).to have_received(:order)
        .with("created_at ASC")
    end
  end

  context 'when sort field is an array' do
    let(:sorter) do
      [
        { field: 'date', order: 'desc' },
        { field: 'createdAt', order: 'ASC' }
      ]
    end

    it 'joins the list' do
      expect(model).to have_received(:order)
        .with("date DESC, created_at ASC")
    end
  end

  context 'when sort field is random' do
    let(:sorter) { { field: 'random', order: 'ASC' } }

    it 'calls the RANDOM() function' do
      expect(model).to have_received(:order)
        .with('RANDOM() ASC')
    end
  end
end

shared_context 'a model with name' do |name|
  let(:table_name) { name.to_s }
  let(name) { double }

  before do
    allow(send(name)).to receive(:name).and_return(name.to_s)
    allow(send(name)).to receive(:table_name).and_return(name.to_s)
    allow(send(name)).to receive(:all).and_return(send(name))
    allow(send(name)).to receive(:where).and_return(send(name))
    allow(send(name)).to receive(:or).and_return(send(name))
    allow(send(name)).to receive(:and).and_return(send(name))
    allow(send(name)).to receive(:not).and_return(send(name))
    allow(send(name)).to receive(:order).and_return(send(name))
  end
end

def build_filters(keys, value)
  filters_hash = GraphqlQuery::Constants::FILTERS

  keys.inject({}) do |acc, curr|
    acc.update(
      curr => filters_hash.keys.inject({}) do |acc, curr|
        acc.update(curr => value)
      end
    )
  end
end

RSpec.describe GraphqlQuery::Main, type: :module do
  include_context 'a model with name', :model

  let(:keys_to_filter) { %w[id name] }
  let(:keys_to_order) { %w[created_at updated_at] }
  let(:filter_value) { 'some_value' }
  let(:search_value) { 'search_value' }
  let(:filter_by) { build_filters(keys_to_filter, filter_value) }
  let(:pagination) { { limit: 10, offset: 5 } }
  let(:sorter) { { field: 'date', order: 'ASC' } }
  let(:search) { { email: search_value, phone: search_value } }
  let(:args) do
    filter_by
      &.merge(pagination)
      &.merge(sort_by: sorter)
      &.merge(search_by: search)
  end
  let(:operator) do
    described_class.new(
      model,
      args
    )
  end

  before do
    filter_by&.each do |_, key_filters|
      key_filters.each do |filter, _|
        allow(GraphqlQuery::Constants::FILTERS[filter][:statement])
          .to receive(:call).and_call_original
      end
    end
  end

  describe '#to_relation' do
    let(:args) do
      {}
        &.merge(filter_by: filter_by)
        &.merge(sort_by: sorter)
        &.merge(search_by: search)
    end

    before { operator.to_relation }

    it_behaves_like 'a call to filtered_model'
    it_behaves_like 'a call to sorted_model'
  end
end
