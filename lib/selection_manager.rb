# frozen_string_literal: true

require './lib/planet'
require './lib/fleet'
require './lib/transfer_lane'

class SelectionManager
  def initialize
    #
  end

  def update
    init_selections

    update_planet_selection
    update_transfer_lane_selection
    launch_fleets

    remove_selections
  end

  def draw
    #
  end

  private

  def init_selections
    @remove_selected = false
  end

  def update_planet_selection
    if $window.button_down_one_shot? Gosu::MsLeft
      puts 'button down'

      if selected_planet
        if planet_moused_over && selected_planet.can_transfer_to?(planet_moused_over)
          load_and_send_fleet selected_planet, planet_moused_over, 100
          queue_selection_removal
        else
          queue_selection_removal
        end
      else
        if planet_moused_over && planet_moused_over.friendly?
          add_planet_selection planet_moused_over
        else
          queue_selection_removal
        end
      end
    end
  end

  def update_transfer_lane_selection
    selected_transfer_lane = TransferLane.selected
    pending_selection_transfer_lanes = moused_over_transfer_lanes

    if pending_selection_transfer_lanes.none?
      TransferLane.unselect_all
    elsif selected_transfer_lane && (moused_over_transfer_lanes.include? selected_transfer_lane)
      # support for switching selected transfer lane goes here...
    else
      moused_over_transfer_lanes.first.select
    end
  end

  def launch_fleets
    selected_transfer_lane = TransferLane.selected
    pending_selection_transfer_lanes = moused_over_transfer_lanes

    if selected_transfer_lane && $window.button_down_one_shot?(Gosu::MsLeft)
      if selected_transfer_lane.within?($window.mouse_x, $window.mouse_y)
        load_and_send_fleet selected_transfer_lane.home_planet,
                            selected_transfer_lane.destination_planet,
                            selected_transfer_lane.percentage_selected
        queue_selection_removal
      end
    end
  end

  def queue_selection_removal
    @remove_selected = true
  end

  def remove_selections
    remove_planet_selection if @remove_selected
  end

  def add_planet_selection planet
    planet.select
    create_transfer_lanes_for planet
  end

  def create_transfer_lanes_for planet_source
    transferrable_planets = $window.planets.select { |planet| planet_source.can_transfer_to? planet }
    transferrable_planets.each do |transferrable_planet|
      $window.add_entities([TransferLane.new(self, planet_source, transferrable_planet)])
    end
  end

  def selected_planet
    $window.planets.select(&:selected?).first
  end

  def planet_moused_over
    $window.planets.select { |planet| planet.within?($window.mouse_x, $window.mouse_y) }.first
  end

  def moused_over_transfer_lanes
    $window.transfer_lanes.select do |transfer_lane|
      transfer_lane.within?($window.mouse_x, $window.mouse_y)
    end
  end

  def remove_planet_selection
    $window.planets.each(&:unselect)
    $window.destroy_entities($window.transfer_lanes)
  end

  def assign_planet_selection_to planet
    planet.select
  end

  def load_and_send_fleet starting_planet, destination_planet, percentage_leaving
    percentage_leaving = percentage_leaving.clamp(1, 100)
    transfering_population = starting_planet.population * (percentage_leaving/100)
    transfering_population = [starting_planet.population - 10, transfering_population].min

    $window.add_entities([Fleet.new(starting_planet, destination_planet, transfering_population)])
    starting_planet.population -= transfering_population
  end
end
