class Undestroy::Config
  OPTIONS = [
    :table_name, :abstract_class, :fields, :migrate, :indexes, :prefix,
    :source_class, :target_class, :internals, :model_paths
  ]
  attr_accessor *OPTIONS

  def initialize(options={})
    self.indexes = false
    self.migrate = true
    self.prefix = "archive_"
    self.fields = {}
    self.model_paths = []
    self.internals = {
      :archive => Undestroy::Archive,
      :transfer => Undestroy::Transfer,
      :restore => Undestroy::Restore
    }

    add_field :deleted_at, :datetime do |instance|
      Time.now
    end

    # Default for Rails apps
    self.model_paths << Rails.root.join('app', 'models') if defined?(Rails)

    options.each do |key, value|
      self[key] = value.duplicable? ? value.dup : value
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
    self.fields.inject({}) do |hash, (key, field)|
      hash.merge(key => field.value(object))
    end
  end

  def add_field(name, *args, &block)
    self.fields[name.to_sym] = Field.new(name, *args, &block)
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

require 'undestroy/config/field'
