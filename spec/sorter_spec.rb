require 'spec_helper'
require 'graphql_query/sorter'

RSpec.describe GraphqlQuery::Sorter, type: :module do
  let(:mod) { described_class }
  let(:model_name) { "Test" }
  let(:fields) { %i[test1 test2 test3] }
  let(:enum_class) do
    Class.new do
      def self.graphql_name(*args); end

      def self.value(*args); end
    end
  end
  let(:sorter_wrapper) do
    Class.new do
      include GraphqlQuery::Sorter
      def graphql_name(*args); end

      def argument(*args); end
    end
  end

  before do
    described_class.enum_class = enum_class
  end

  describe '.include_sort_arguments' do
    let(:wrapper) { sorter_wrapper.new }
    let(:action) { wrapper.include_sort_arguments(model_name, fields) }
    let(:sortable_field) { class_double(described_class.enum_class) }

    before do
      allow(Object).to receive(:const_set).and_return(sortable_field)
      allow(wrapper).to receive(:graphql_name)
      allow(wrapper).to receive(:argument)
      allow(sortable_field).to receive(:graphql_name)
      allow(sortable_field).to receive(:value)
      action
    end

    it 'creates correct arguments' do
      expect(wrapper).to have_received(:graphql_name).with("#{model_name}SortInput")
      expect(wrapper).to have_received(:argument).with(
        :field,
        sortable_field,
        description: "Sortable field",
        required: true
      )
    end

    it 'creates correct fields' do
      expect(sortable_field).to have_received(:graphql_name).with("#{model_name}SortableField")

      fields.each do |key|
        expect(sortable_field).to have_received(:value).with(key, "Sort by #{key}")
      end
    end
  end
end
