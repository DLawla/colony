# frozen_string_literal: true

require './lib/planet'
require './lib/fleet_traffic_control'
require './lib/transfer_lane'

class SelectionManager
  def initialize
  end

  def update
    transfer_lane_selection
    planet_hover_over
    planet_and_fleet_selection
  end

  def draw
    #
  end

  private

  def transfer_lane_selection
    # On hover over transfer lanes, change which is selected

    selected_transfer_lane = TransferLane.selected
    pending_selection_transfer_lanes = moused_over_transfer_lanes

    if pending_selection_transfer_lanes.none?
      TransferLane.unselect_all
    elsif selected_transfer_lane && (moused_over_transfer_lanes.include? selected_transfer_lane)
      # support for switching selected transfer lane goes here...
    else
      TransferLane.unselect_all
      moused_over_transfer_lanes.first.select
    end
  end

  def planet_hover_over
    if selected_planet
      if planet_moused_over && selected_planet.can_transfer_to?(planet_moused_over)
        planet_moused_over.hovered_over
      end
    else
      if planet_moused_over && planet_moused_over.friendly?
        planet_moused_over.hovered_over
      end
    end
  end

  def planet_and_fleet_selection
    # Manage planet & transfer lane selection/unselection and launching fleets
    if $window.button_down_one_shot? Gosu::MsLeft
      puts 'button down'

      selected_transfer_lane = TransferLane.selected

      if selected_planet
        if planet_moused_over && selected_planet.can_transfer_to?(planet_moused_over)
          FleetTrafficControl.new.send_fleet selected_planet, planet_moused_over, 100
          remove_planet_selection
        elsif selected_transfer_lane && selected_transfer_lane.within?($window.mouse_x, $window.mouse_y)
          FleetTrafficControl.new.send_fleet selected_transfer_lane.home_planet,
                                             selected_transfer_lane.destination_planet,
                                             selected_transfer_lane.percentage_selected
          remove_planet_selection
        else
          remove_planet_selection
        end
      else
        if planet_moused_over && planet_moused_over.friendly?
          add_planet_selection planet_moused_over
        else
          remove_planet_selection
        end
      end
    end
  end

  def remove_selections
    remove_planet_selection
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
end
