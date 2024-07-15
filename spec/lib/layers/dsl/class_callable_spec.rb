# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layers::DSL::ClassCallable do

  subject(:test_class) do
    Class.new.include described_class
  end

  describe 'Inclusion' do
    describe 'ClassMethods' do

      it { is_expected.to respond_to(:call) }

      describe '.call' do
        let(:test_instance) { double('test_instance', call: true) }

        before do
          allow(test_class).to receive(:new).and_return(test_instance)
        end

        execute do
          test_class.call
        end

        it 'instantiates an instance of the class' do
          expect(test_class).to have_received(:new)
        end

        it 'sends the message :call to the instance' do
          expect(test_instance).to have_received(:call)
        end
      end

      describe 'Duck Typing enforcement' do
        describe '#call' do
          context 'when not implemented' do
            it 'raises NotImplementedError' do
              expect { test_class.call }.to raise_error(NotImplementedError)
            end
          end

          context 'when implemented' do
            let(:test_class_with_call) do
              Class.new do
                include Layers::DSL::ClassCallable

                def call
                  'implemented'
                end
              end
            end

            it 'does not raise an error' do
              expect { test_class_with_call.call }.not_to raise_error
            end
          end
        end
      end
    end
  end

end
