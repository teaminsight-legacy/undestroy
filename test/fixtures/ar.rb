
class Undestroy::Test::Fixtures::ARFixture
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

  # Shortcut to build an instance for testing purposes.
  def self.construct(attributes={})
    self.new.tap do |fixture|
      attributes.each do |field, value|
        fixture[field] = value
      end
    end
  end

end

