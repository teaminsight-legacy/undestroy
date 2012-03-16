
class Undestroy::Binding::ActiveRecord::MigrationStatement

  SCHEMA = [
    :create_table, :drop_table, :rename_table,
    :add_column, :rename_column, :change_column, :remove_column,
  ]

  INDEX = [
    :add_index, :remove_index
  ]

  attr_accessor :method_name, :arguments, :block

  def initialize(method_name, *args, &block)
    self.method_name = method_name
    self.arguments = args
    self.block = block
  end

  def source_table_name
    self.arguments[0]
  end

  def target_table_name
    config.target_class.table_name
  end

  def config
    Undestroy::Config.catalog.select do |c|
      c.source_class.respond_to?(:table_name) &&
      c.source_class.table_name.to_s == source_table_name.to_s
    end.first
  end

  def schema_action?
    SCHEMA.include?(method_name)
  end

  def index_action?
    INDEX.include?(method_name)
  end

  def run?
    (
      arguments.present? &&
      config &&
      config.migrate &&
      schema_action?
    )
  end

end

