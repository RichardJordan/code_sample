# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layers::Base do
  let(:listener) { double('listener') }
  let(:on_failure) { :custom_failure }
  let(:on_success) { :custom_success }

  let(:test_layer_class) { Class.new(described_class) }

  describe 'Inclusion' do
    subject(:sub_class) { test_layer_class }

    describe 'Adds modules to subclasses' do
      it_behaves_like 'it adds to inheritance hierarchy', Layers::DSL::ClassCallable
      it_behaves_like 'it adds to inheritance hierarchy', Layers::DSL::DefaultCallbacks
      it_behaves_like 'it adds to inheritance hierarchy', Layers::DSL::NullListener
      it_behaves_like 'it adds to inheritance hierarchy', Layers::DSL::Inputs
      it_behaves_like 'it adds to inheritance hierarchy', Layers::DSL::Observers
    end

    describe 'Mixes in ActiveModel::Validations' do
      it_behaves_like 'it adds to inheritance hierarchy', ActiveModel::Validations
    end
  end

  describe '#initialize' do
    subject(:sub_class_instance) do
      test_layer_class.allocate
    end

    let(:default_on_failure) { double('default_on_failure') }
    let(:default_on_success) { double('default_on_success') }


    context 'when listener and callbacks are provided' do

      execute do
        sub_class_instance.send :initialize,
                                listener: listener,
                                on_failure: on_failure,
                                on_success: on_success
      end

      it 'assigns the listener' do
        expect(sub_class_instance.listener).to eq(listener)
      end

      it 'assigns the on_failure callback' do
        expect(sub_class_instance.on_failure).to eq(on_failure)
      end

      it 'assigns the on_success callback' do
        expect(sub_class_instance.on_success).to eq(on_success)
      end
    end

    context 'when no listener or callbacks are provided' do

      let(:null_listener) { double('null_listener') }
      let(:default_on_failure) { double('default_on_failure') }
      let(:default_on_success) { double('default_on_success') }

      before do
        allow(sub_class_instance).to receive_messages(
          null_listener: null_listener,
          on_failure_default: default_on_failure,
          on_success_default: default_on_success,
        )
      end

      execute do
        sub_class_instance.send :initialize
      end

      it 'assigns a default null_listener' do
        expect(sub_class_instance.listener).to eq(null_listener)
      end

      it 'assigns a default on_failure callback' do
        expect(sub_class_instance.on_failure).to eq(default_on_failure)
      end

      it 'assigns a default on_success callback' do
        expect(sub_class_instance.on_success).to eq(default_on_success)
      end
    end
  end

  describe 'Callback Triggers' do
    describe 'private#failure' do
      subject(:sub_class_instance) do
        test_layer_class.new(listener: listener, on_failure: on_failure)
      end

      before do
        allow(sub_class_instance).to receive(:notify_observers)
        allow(listener).to receive(on_failure)
      end

      execute do
        sub_class_instance.send(:failure)
      end

      it 'notifies observers of :failure event' do
        expect(sub_class_instance).to have_received(:notify_observers).with(of_event: :failure)
      end
    end

    describe 'private#success' do
      subject(:sub_class_instance) do
        test_layer_class.new(listener: listener, on_success: on_success)
      end

      before do
        allow(sub_class_instance).to receive(:notify_observers)
        allow(listener).to receive(on_success)
      end

      execute do
        sub_class_instance.send(:success)
      end

      it 'notifies observers of :success event' do
        expect(sub_class_instance).to have_received(:notify_observers).with(of_event: :success)
      end

      it 'calls the on_success method on the listener' do
        expect(listener).to have_received(on_success)
      end
    end
  end

end
