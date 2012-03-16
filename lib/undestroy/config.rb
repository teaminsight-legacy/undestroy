class Undestroy::Config
  OPTIONS = [
    :table_name, :abstract_class, :fields, :migrate,
    :source_class, :target_class, :internals
  ]
  attr_accessor *OPTIONS

  def initialize(options={})
    self.migrate = true
    self.fields = {
      :deleted_at => proc { Time.now }
    }
    self.internals = {
      :archive => Undestroy::Archive,
      :transfer => Undestroy::Transfer,
    }

    options.each do |key, value|
      self[key] = value
    end

    self.class.catalog << self
  end

  def [](key)
    self.send(key) if OPTIONS.include?(key)
  end

  def []=(key, value)
    self.send("#{key}=", value) if OPTIONS.include?(key)
  end

  def to_hash
    OPTIONS.inject({}) { |hash, key| hash.merge(key => self[key]) }
  end

  def merge(object)
    self.class.new(self.to_hash.merge(object.to_hash))
  end

  def primitive_fields(object)
    self.fields.inject({}) do |hash, (key, val)|
      hash.merge(key => val.is_a?(Proc) ? val.call(object) : val)
    end
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.config
    @config ||= self.new
  end

  def self.catalog
    @@catalog ||= []
  end

  def self.reset_catalog
    @@catalog = []
  end

end

