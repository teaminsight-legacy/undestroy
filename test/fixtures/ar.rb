
class Undestroy::Test::Fixtures::ARFixture
  attr_accessor :attributes
  attr_reader :saved

  alias :saved? :saved

  def initialize(attributes={})
    @saved = false
    self.attributes = HashWithIndifferentAccess.new(attributes)
    self.attributes.delete(:id)
  end

  def [](key)
    @attributes[key]
  end

  def []=(key, val)
    @attributes[key] = val
  end

  # Method missing won't catch this one
  def id
    self[:id]
  end

  def attributes
    @attributes.stringify_keys
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

