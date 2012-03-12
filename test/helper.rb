require 'undestroy'

class ARFixture
  attr_accessor :attributes
  attr_reader :saved

  alias :saved? :saved

  def initialize(attributes={})
    @saved = false
    self.attributes = attributes.dup
    self.attributes.delete(:id)
  end

  def [](key)
    self.attributes[key.to_sym]
  end

  def []=(key, val)
    self.attributes[key.to_sym] = val
  end

  # Method missing won't catch this one
  def id
    self.attributes[:id]
  end

  def save
    @saved = true
  end

end

