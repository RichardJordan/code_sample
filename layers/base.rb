# frozen_string_literal: true

require 'active_model'

module Layers
  class Base
    include ActiveModel::Validations

    include Layers::DSL::Observers
    include Layers::DSL::Inputs
    include Layers::DSL::NullListener
    include Layers::DSL::DefaultCallbacks
    include Layers::DSL::ClassCallable

    attr_reader :listener, :on_failure, :on_success


    def initialize(listener: nil, on_failure: nil, on_success: nil, **opts)
      @listener = listener || null_listener
      @on_failure = on_failure || on_failure_default
      @on_success = on_success || on_success_default

      super(opts)
    end


    private

    def failure(*failure_args, **failure_opts)
      notify_observers(of_event: :failure)
      listener.public_send(on_failure, *failure_args, **failure_opts)
    end

    def success(*success_args, **success_opts)
      notify_observers(of_event: :success)
      listener.public_send(on_success, *success_args, **success_opts)
    end

  end
end
