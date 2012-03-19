module Undestroy::Binding
  autoload :ActiveRecord, 'undestroy/binding/active_record'

  def self.bind
    Undestroy::Binding::ActiveRecord.add(::ActiveRecord::Base)
    Undestroy::Binding::ActiveRecord::MigrationStatement.add(::ActiveRecord::Migration)
  end
end

