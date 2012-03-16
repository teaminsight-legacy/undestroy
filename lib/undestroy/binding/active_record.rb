require 'active_record'

class Undestroy::Binding::ActiveRecord

  attr_accessor :config, :model

  def initialize(model, options={})
    ensure_is_ar! model

    self.model = model
    self.config = Undestroy::Config.config.merge(options)

    set_defaults
  end

  def before_destroy(instance)
    config.internals[:archive].new(:config => config, :source => instance).run
  end

  protected

  def set_defaults
    self.config.source_class = self.model
    self.config.table_name ||= table_prefix + self.model.table_name if self.model.respond_to?(:table_name)
    self.config.target_class ||= create_target_class
    ensure_is_ar! self.config.target_class
  end

  # Builds a dynamic AR class representing the archival table
  def create_target_class
    Class.new(self.config.abstract_class || ActiveRecord::Base).tap do |target_class|
      target_class.table_name = self.config.table_name
    end
  end

  def table_prefix
    "archive_"
  end

  def ensure_is_ar!(klass)
    raise ArgumentError, "#{klass.inspect} must be an ActiveRecord model" unless is_ar?(klass)
  end

  def is_ar?(klass)
    klass.is_a?(Class) && klass.ancestors.include?(ActiveRecord::Base)
  end

  # Add binding to the given class if it doesn't already have it
  def self.add(klass=ActiveRecord::Base)
    klass.class_eval do
      class_attribute :undestroy_model_binding, :instance_writer => false

      def self.undestroy(options={})
        before_destroy do
          self.undestroy_model_binding.before_destroy(self) if undestroy_model_binding
        end unless self.undestroy_model_binding
        self.undestroy_model_binding = Undestroy::Binding::ActiveRecord.new(self, options)
      end

    end unless klass.respond_to?(:undestroy_model_binding)
  end

end

require 'undestroy/binding/active_record/migration_statement'

