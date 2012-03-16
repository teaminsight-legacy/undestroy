
class Undestroy::Binding::ActiveRecord::MigrationStatement

  attr_accessor :method_name, :arguments, :block

  def initialize(method_name, *args, &block)
    self.method_name = method_name
    self.arguments = args
    self.block = block
  end

end

