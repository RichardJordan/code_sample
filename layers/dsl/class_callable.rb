# frozen_string_literal: true

module Layers
  module DSL
    module ClassCallable

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def call(*args, **opts)
          new(*args, **opts).call
        end
      end

      # Enforce the implementation of the call method

      def call
        raise NotImplementedError
      end
    end
  end
end
