# frozen_string_literal: true

module HasState
  def self.included(base)
    attr_reader :state
  end

  module ClassMethods
  end

  def starting_menu!
    @game_state = :starting_menu
    $window.load_starting_menu
  end

  def starting_menu?
    @game_state == :starting_menu
  end

  def start_game!
    @game_state = :in_game
    $window.load_game_start
  end

  def started?
    @game_state == :in_game
  end

  def end_game!
    @game_state == :ended
    $window.load_end_menu
  end

  def game_ended?
    @game_state == :ended
  end
end