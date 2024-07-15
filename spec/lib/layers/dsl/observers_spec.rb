# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layers::DSL::Observers do
  subject(:test_class) { Class.new.include Layers::DSL::Observers }

  describe 'Inclusion' do
    describe 'ClassMethods' do
      it { is_expected.to respond_to(:observer) }
      it { is_expected.to respond_to(:observers) }
      it { is_expected.to respond_to(:observer_exception_handler) }
      it { is_expected.to respond_to(:observer_exception_handler_method) }

      describe '.observer' do
        context 'when adding a single observer method' do
          before { test_class.observer(:my_observer, of_event: :success) }

          it 'adds the observer method to the specified event' do
            expect(test_class.observers[:success]).to include(:my_observer)
          end
        end

        context 'when adding multiple observer methods' do
          before { test_class.observer(:observer_one, :observer_two, of_event: :failure) }

          it 'adds all observer methods to the specified event' do
            expect(test_class.observers[:failure]).to include(:observer_one, :observer_two)
          end
        end
      end

      describe '.observers' do
        it 'returns a hash of observers' do
          expect(test_class.observers).to be_a(Hash)
        end
      end

      describe '.observer_exception_handler' do
        before { test_class.observer_exception_handler(:handle_exception) }

        it 'sets the observer exception handler method' do
          expect(test_class.observer_exception_handler_method).to eq(:handle_exception)
        end
      end
    end

    describe 'InstanceMethods' do
      subject(:test_instance) { test_class.new }

      before do
        test_class.define_method(:my_observer) { |*_args| true }
        test_class.observer(:my_observer, of_event: :success)
      end

      it { is_expected.to respond_to(:notify_observers) }
      it { is_expected.to respond_to(:observers) }

      describe '#notify_observers' do
        context 'when observers are present' do
          before do
            allow(test_instance).to receive(:my_observer)
          end

          execute do
            test_instance.notify_observers(of_event: :success)
          end

          it 'invokes the observer methods' do
            expect(test_instance).to have_received(:my_observer)
          end
        end

        context 'when an observer method raises an exception' do
          before do
            test_class.define_method(:handle_exception) { |*_args| true }
            test_class.observer_exception_handler(:handle_exception)
            allow(test_instance).to receive(:my_observer).and_raise(StandardError)
            allow(test_instance).to receive(:handle_exception)
          end

          execute do
            test_instance.notify_observers(of_event: :success)
          end

          it 'handles the exception using the specified handler' do
            expect(test_instance).to have_received(:handle_exception)
          end
        end
      end

      describe '#observers' do
        it 'returns a hash of observers of class events' do
          expect(test_instance.observers).to eq(test_class.observers)
        end
      end

      describe '#handle_observer_exception' do
        let(:logger) { spy('Logger') }
        let(:exception) { StandardError.new('Test exception') }

        before do
          test_class.define_method(:handle_exception) { |*_args| true }
          test_class.observer_exception_handler(:handle_exception)

          allow(test_instance).to receive(:handle_exception)
          allow(test_instance).to receive(:logger).and_return(logger)
        end

        execute do
          test_instance.send(:handle_observer_exception, exception)
        end

        it 'calls the exception handler method if it is defined' do
          expect(test_instance).to have_received(:handle_exception).with(exception)
        end

        it 'logs a warning message' do
          expect(logger).to have_received(:warn).with("#{test_class} observers failed with #{exception.message}")
        end

        it 'logs the exception backtrace' do
          expect(logger).to have_received(:debug).with(exception.backtrace&.join("\n"))
        end
      end
    end
  end
end
