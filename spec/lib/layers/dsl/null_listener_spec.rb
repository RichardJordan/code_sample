# frozen_string_literal: true

require 'rails_helper'
require 'naught'

RSpec.describe Layers::DSL::NullListener do

  subject(:instance) { dummy_class.new }

  let(:dummy_class) do
    Class.new do
      include Layers::DSL::NullListener
    end
  end


  describe 'Inclusion' do
    describe 'InstanceMethods' do
      describe 'private#null_listener' do

        subject(:null_listener) { instance.send :null_listener }

        describe 'returns a null object' do
          it 'which responds to all messages with nil' do
            [:foo, :bar, :save, :call, Faker::Lorem.word].each do |method_name|
              expect(null_listener.send(method_name)).to be_nil
            end
          end
        end
      end
    end
  end
end
