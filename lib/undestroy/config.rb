class Undestroy::Config
  OPTIONS = [:archive_table, :archive_klass, :archive_connection, :fields, :migrate]
  attr_accessor *OPTIONS

  def initialize(options={})
    self.migrate = true
    self.fields = {
      :deleted_at => proc { Time.now }
    }

    options.each do |key, value|
      self[key] = value
    end
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

  def self.configure
    yield(config) if block_given?
  end

  def self.config
    @config ||= self.new
  end

end

