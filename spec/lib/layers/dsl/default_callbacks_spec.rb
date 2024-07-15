# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layers::DSL::DefaultCallbacks do
  subject(:test_class) { Class.new.include Layers::DSL::DefaultCallbacks }

  describe 'Inclusion' do
    describe 'ClassMethods' do
      it { is_expected.to respond_to(:default_callbacks) }
      it { is_expected.to respond_to(:on_failure_default) }
      it { is_expected.to respond_to(:on_success_default) }

      describe '.default_callbacks' do
        let(:custom_callbacks) { { on_failure: :custom_failure, on_success: :custom_success } }

        context 'when custom callbacks are provided' do
          before { test_class.default_callbacks(**custom_callbacks) }

          it 'sets the custom on_failure callback' do
            expect(test_class.on_failure_default).to eq(:custom_failure)
          end

          it 'sets the custom on_success callback' do
            expect(test_class.on_success_default).to eq(:custom_success)
          end
        end

        context 'when custom callbacks are not provided' do
          before { test_class.default_callbacks }

          it 'sets the default on_failure callback' do
            expect(test_class.on_failure_default).to eq(:on_failure)
          end

          it 'sets the default on_success callback' do
            expect(test_class.on_success_default).to eq(:on_success)
          end
        end
      end

      describe '.on_failure_default' do
        it 'returns the default on_failure callback' do
          expect(test_class.on_failure_default).to eq(:on_failure)
        end
      end

      describe '.on_success_default' do
        it 'returns the default on_success callback' do
          expect(test_class.on_success_default).to eq(:on_success)
        end
      end
    end

    describe 'InstanceMethods' do
      subject(:test_instance) { test_class.new }

      before { test_class.default_callbacks }

      it { is_expected.to respond_to(:on_failure_default) }
      it { is_expected.to respond_to(:on_success_default) }

      describe '#initialize' do
        it 'sets the on_failure_default instance variable from the class' do
          expect(test_instance.on_failure_default).to eq(:on_failure)
        end

        it 'sets the on_success_default instance variable from the class' do
          expect(test_instance.on_success_default).to eq(:on_success)
        end
      end
    end
  end
end
