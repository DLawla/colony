# frozen_string_literal: true

require './lib/contenders/base_contender'

module Opponents
  class Human < BaseContender
    def update
      #
    end

    def human?
      true
    end
  end
end
