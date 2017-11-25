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
    @faction = case faction
                 when :friendly
                   :friendly
                 when :enemy
                   :enemy
                 else
                   :neutral
               end
  end

  def change_faction_to new_faction
    @faction = new_faction
  end

  def friendly?
    @faction == :friendly
  end

  def enemy?
    @faction == :enemy
  end

  def neutral?
    !friendly? && !enemy?
  end

  def faction_color
    return Gosu::Color::GREEN if friendly?
    return Gosu::Color::RED  if enemy?
    Gosu::Color::YELLOW
  end
end