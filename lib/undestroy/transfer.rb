
class Undestroy::Transfer
  attr_accessor :target

  def initialize(config={})
    raise ArgumentError, ":klass option required" unless config[:klass]
    config[:fields] ||= {}

    self.target = config[:klass].new

    # Set instance values directly to avoid AR's filtering of protected fields
    config[:fields].each do |field, value|
      self.target[field] = value
    end
  end

  def run
    self.target.save
  end

end

