class Undestroy::Config::Field

  attr_accessor :name, :type, :raw_value

  def <=>(b)
    name.to_s <=> b.name.to_s
  end

  def initialize(name, type, value=nil, &block)
    self.name = name
    self.type = type
    self.raw_value = block || value || raise(ArgumentError, "Must pass a value or block")
  end

  def value(*args)
    raw_value.is_a?(Proc) ? raw_value.call(*args) : raw_value
  end

end

