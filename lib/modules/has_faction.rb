module HasFaction
  def self.included(base)
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

  def make_friendly
    @faction = :friendly
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