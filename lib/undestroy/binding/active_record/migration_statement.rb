
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

  def target_arguments
    self.arguments.dup.tap do |args|
      args[0] = target_table_name
      args[1] = binding.prefix_table_name(args[1]) if rename_table?
    end
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
      config && config.migrate &&
      !rename_table_exception? &&
      (
        schema_action? ||
        index_action? && config.indexes
      )
    )
  end

  def run!(callable)
    callable.call(method_name, *target_arguments, &block)

    if create_table?
      config.fields.values.each do |field|
        callable.call(:add_column, target_table_name, field.name, field.type)
      end
    end
  end

  protected

  # We don't want to run rename_table on the target when the table name is
  # explicitly set in the configuration.  The user must do manual migrating
  # in that case.
  def rename_table_exception?
    rename_table? && config.table_name
  end

  def create_table?
    method_name == :create_table
  end

  def rename_table?
    method_name == :rename_table
  end

  def binding
    config.source_class.undestroy_model_binding
  end
end

