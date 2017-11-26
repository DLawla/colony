# frozen_string_literal: true

module HasFaction
  def self.included(base)
    attr_accessor :faction

    base.extend(ClassMethods)
  end

  module ClassMethods
    def of_faction(faction)
      $window.entities.select { |has_faction| has_faction.is_a?(self) && has_faction.faction == faction }
    end
  end

  def assign_faction faction
    @faction = faction
  end

  def change_faction_to new_faction
    @faction = new_faction
  end

  def has_faction?
    @faction
  end

  def human?
    @faction == 0
  end

  # def friendly?
  #   @faction == :friendly
  # end
  #
  # def enemy?
  #   @faction == :enemy
  # end
  #
  # def neutral?
  #   !friendly? && !enemy?
  # end

  def faction_color
    return Gosu::Color::GREEN if @faction == 0
    return Gosu::Color::RED  if @faction == 1
    return Gosu::Color::BLUE  if @faction == 2
    Gosu::Color::YELLOW
  end
end