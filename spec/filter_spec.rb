require 'spec_helper'
require 'graphql_query/filter'

RSpec.describe GraphqlQuery::Filter, type: :module do
  let(:filter_wrapper) do
    Class.new do
      include GraphqlQuery::Filter
      def argument(*args); end
    end
  end

  describe '.include_filter_arguments' do
    let(:type) { "Any" }
    let(:wrapper) { filter_wrapper.new }
    let(:filters) { GraphqlQuery::Constants::FILTERS }
    let(:action) { wrapper.include_filter_arguments(type, args) }

    before { allow(wrapper).to receive(:argument) }

    context 'when all required filters are valid' do
      let(:args) { filters.keys }

      it 'creates an argument for each filter constant' do
        expect { action }.not_to raise_exception

        filters.each do |key, value|
          expect(wrapper).to have_received(:argument)
            .with(
              key,
              value[:transform_type].call(type),
              description: value[:description],
              required: false
            )
        end
      end
    end

    context 'when and invalid filter is send' do
      let(:args) { %i[invalid] }

      it 'raises an ArgumentError' do
        expect { action }.to raise_exception(ArgumentError)
      end
    end
  end
end
