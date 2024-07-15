# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layers::DSL::Inputs do

  subject(:test_class) { Class.new.include described_class }

  describe 'Inclusion' do
    describe 'ClassMethods' do

      it { is_expected.to respond_to(:all_inputs) }
      it { is_expected.to respond_to(:default_inputs) }
      it { is_expected.to respond_to(:optional) }
      it { is_expected.to respond_to(:optional_inputs) }
      it { is_expected.to respond_to(:optional_with_default) }
      it { is_expected.to respond_to(:required) }
      it { is_expected.to respond_to(:required_inputs) }

      describe '.all_inputs' do

        subject(:test_class_with_multiple_inputs) do
          Class.new do
            include Layers::DSL::Inputs
            required :foo, :bar
            optional :baz, :qux
          end
        end

        it 'returns a list of all inputs' do
          expect(test_class_with_multiple_inputs.all_inputs).to include(:foo, :bar, :baz, :qux)
        end
      end

      describe '.optional' do
        context 'with an input name argument' do

          subject(:test_instance) { test_class_with_optional_input.allocate }

          let(:test_class_with_optional_input) do
            Class.new do
              include Layers::DSL::Inputs
              optional :foo
            end
          end


          it 'adds the input name to optional_inputs' do
            expect(test_class_with_optional_input.optional_inputs).to include(:foo)
          end

          it 'adds instance reader method for the input' do
            expect(test_instance).to respond_to(:foo)
          end

          it 'adds instance writer method for the input' do
            expect(test_instance).to respond_to(:foo=)
          end
        end

        context 'with an argument list of multiple input names' do

          subject(:test_class_with_optional_inputs) do
            Class.new do
              include Layers::DSL::Inputs
              optional :foo, :bar
            end
          end

          it 'adds each input name to optional inputs' do
            expect(test_class_with_optional_inputs.optional_inputs).to include(:foo, :bar)
          end
        end
      end

      describe '.optional_with_defaults' do
        context 'with an input name key / default value pair as an argument' do

          subject(:test_instance) { test_class_with_optional_default.allocate }

          let(:test_class_with_optional_default) do
            Class.new do
              include Layers::DSL::Inputs
              optional_with_default foo: []
            end
          end


          it 'adds the input name to optional_inputs' do
            expect(test_class_with_optional_default.optional_inputs).to include(:foo)
          end

          it 'adds the input name to default inputs' do
            expect(test_class_with_optional_default.default_inputs).to include(:foo)
          end

          it 'adds the default value to default inputs for that input names' do
            expect(test_class_with_optional_default.default_inputs[:foo]).to eq([])
          end

          it 'adds instance reader method for the input' do
            expect(test_instance).to respond_to(:foo)
          end

          it 'adds instance writer method for the input name' do
            expect(test_instance).to respond_to(:foo=)
          end
        end

        context 'with a hash of multiple input name / default value pairs' do

          subject(:test_class) do
            Class.new do
              include Layers::DSL::Inputs
              optional_with_default foo: [], bar: {}
            end
          end

          it 'adds each input name to optional inputs' do
            expect(test_class.optional_inputs).to include(:foo, :bar)
          end

          it 'adds each default value to the default input for the corresponding input name' do
            expect(test_class.default_inputs).to eq({ foo: [], bar: {} })
          end
        end
      end

      describe '.required' do
        context 'with an input name argument' do

          subject(:test_instance) { test_class_with_required_input.allocate }

          let(:test_class_with_required_input) do
            Class.new do
              include Layers::DSL::Inputs
              required :foo
            end
          end


          it 'adds the input name to required inputs' do
            expect(test_class_with_required_input.required_inputs).to include(:foo)
          end

          it 'adds instance reader method for the input' do
            expect(test_instance).to respond_to(:foo)
          end

          it 'adds instance writer method for the input' do
            expect(test_instance).to respond_to(:foo=)
          end
        end

        context 'with an argument list of multiple input names' do
          subject(:test_class_with_required_inputs) do
            Class.new do
              include Layers::DSL::Inputs
              required :foo, :bar
            end
          end

          it 'adds each input name to optional inputs' do
            expect(test_class_with_required_inputs.required_inputs).to include(:foo, :bar)
          end
        end
      end
    end

    describe 'InstanceMethods' do

      subject(:test_instance) { test_class.allocate }

      let(:test_class) do
        Class.new do
          include Layers::DSL::Inputs
          required :foo, :bar
          optional :baz, :qux
        end
      end

      describe 'Accessors' do
        it { is_expected.to respond_to(:inputs) }
        it { is_expected.to respond_to(:attributes) }
        it { is_expected.to respond_to(:optional_attributes) }
        it { is_expected.to respond_to(:required_attributes) }
      end

      describe '#initialize' do
        let(:required_inputs) { { foo: 'quux', bar: 'corge' } }
        let(:optional_inputs) { { baz: :grault } }

        let(:valid_inputs) { required_inputs.merge(optional_inputs) }

        context 'with valid inputs' do

          before do
            test_instance.send :initialize, **valid_inputs
          end

          it 'sets the inputs variable to the hash of keyword arguments' do
            expect(test_instance.inputs).to eq(valid_inputs)
          end

          it 'sets the attributes for all of the inputs' do
            valid_inputs.each do |name, value|
              expect(test_instance.send(name)).to eq(value)
            end
          end
        end

        context 'with missing required inputs' do
          let(:invalid_inputs) { optional_inputs }

          it 'raises an exception' do
            expect do
              test_instance.send(:initialize, **invalid_inputs)
            end.to raise_error Layers::DSL::MissingRequiredInputs
          end
        end

        context 'with extra invalid inputs' do
          let(:invalid_inputs) do
            required_inputs.merge({ baz: 'grault', qux: 'garply', waldo: :fred })
          end

          it 'raises an exception' do
            expect do
              test_instance.send(:initialize, **invalid_inputs)
            end.to raise_error(Layers::DSL::UnexpectedInputs)
          end
        end

        context 'with default values' do

          subject(:test_instance) { test_class.allocate }

          let(:test_class) do
            Class.new do
              include Layers::DSL::Inputs
              required :foo, :bar
              optional :baz, :qux
              optional_with_default qux: :quux
            end
          end

          execute do
            test_instance.send :initialize, **valid_inputs
          end

          it 'adds default values' do
            expect(test_instance.inputs).to eq(valid_inputs.merge(qux: :quux))
          end
        end
      end

      context 'with valid inputs' do
        let(:required_inputs) { { foo: 'quux', bar: 'corge' } }
        let(:optional_inputs) { { baz: :grault } }

        let(:valid_inputs) { required_inputs.merge(optional_inputs) }

        before do
          test_instance.send :initialize, **valid_inputs
        end

        describe '#attributes' do
          let(:expected) do
            {
              foo: 'quux',
              bar: 'corge',
              baz: :grault,
              qux: nil,
            }
          end

          it 'returns a hash of all inputs with their values, with nil as default' do
            expect(test_instance.attributes).to eq(expected)
          end
        end

        describe '#optional_attributes' do
          it 'returns the optional inputs as key value pairs, with default value nil' do
            expect(test_instance.optional_attributes).to eq({ baz: :grault, qux: nil })
          end
        end

        describe '#required_attributes' do
          it 'returns the required inputs inputs as key value pairs' do
            expect(test_instance.required_attributes).to eq({ foo: 'quux', bar: 'corge' })
          end
        end
      end
    end
  end
end
