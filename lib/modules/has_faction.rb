module HasFaction
  def self.included(base)
    attr_accessor :faction

    base.extend(ClassMethods)
  end

  module ClassMethods
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
end