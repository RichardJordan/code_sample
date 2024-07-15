# frozen_string_literal: true

module Layers
  module DSL
    class MissingRequiredInputs < ArgumentError; end
    class UnexpectedInputs < ArgumentError; end

    class NotImplementedError < NotImplementedError; end
  end
end
