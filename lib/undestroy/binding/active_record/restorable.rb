module Undestroy::Binding::ActiveRecord::Restorable

  def restore
    restore_copy
    destroy
  end

  def restore_copy
    config = undestroy_model_binding.config
    config.internals[:restore].new(:target => self, :config => config).run
  end

  module RelationExtensions

    def restore_all
      to_a.collect { |record| record.restore }.tap { reset }
    end

  end

  def self.included(receiver)
    receiver.send(:relation).singleton_class.class_eval do
      include Undestroy::Binding::ActiveRecord::Restorable::RelationExtensions
    end
  end

end

