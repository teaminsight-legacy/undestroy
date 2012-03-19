
class Undestroy::Test::Fixtures::Archive
  def initialize(args)
    @@data[:args] = args
  end

  def run
    @@data[:calls] << [:run]
  end

  def self.data
    @@data
  end

  def self.reset
    @@data = { :calls => [] }
  end
end

Undestroy::Test::Fixtures::Archive.reset

