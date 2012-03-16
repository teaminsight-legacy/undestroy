require 'assert'

module Undestroy::Binding::ActiveRecord::MigrationStatement::Test

  class Base < Undestroy::Test::Base
    desc 'Binding::ActiveRecord::MigrationStatement class'
    subject { @subject_class }

    setup do
      @subject_class = Undestroy::Binding::ActiveRecord::MigrationStatement
    end

  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { @subject_class.new :foo }

    should have_accessor :method_name, :arguments, :block
  end

  class InitMethod < Base
    desc 'init method'

    should "set required arg1 to method_name attr" do
      obj = subject.new :method
      assert_equal :method, obj.method_name
    end

    should "set remaining args to arguments attr as Array" do
      obj = subject.new :method, :arg1, 'arg2', 3, :four => :val1, :five => :val2
      assert_equal [:arg1, 'arg2', 3, { :four => :val1, :five => :val2 }], obj.arguments
    end

    should "set optional block to block attr" do
      block = proc { "FOOO" }
      obj = subject.new :method, &block
      assert_equal block, obj.block
      assert_equal "FOOO", obj.block.call
    end
  end

  class OriginalTableNameMethod < Base
    desc 'original_table_name method'

    should "return arguments[0]"
  end

  class ArchiveTableNameMethod < Base
    desc 'archive_table_name method'

    should 'return "archive_#{original_table_name}" when :table_name config not set'
    should 'return :table_name config value when set'
  end

  class ConfigMethod < Base
    desc 'config method'

    should "fetch config object for the given table name from Undestroy::Config.catalog"
  end

  class SchemaActionMethod < Base
    desc 'schema_action? method'

    should "return true if method_name is a schema modification method"
    should "return false otherwise"
  end

  class IndexActionMethod < Base
    desc 'index_action? method'

    should "return true if method_name is an index modification method"
    should "return false otherwise"
  end

  class RunQueryMethod < Base
    desc 'run? method'

    should "always return false if arguments are empty"
    should "always return false if no configuration is present for this *source* table name"
    should "return true if :migrate is configured and schema_action? is true"
    should "return false if :migrate is configured and schema_action? is false"
    should "return false if :migrate not configured for this table"
    should "return true if :index is configured and index_action? is true"
    should "return false if :index is configured and index_action? is false"
    should "return false if :index is not configured for this table"

    # We will not rename a table that has been configured to a specific name
    should "return false if :method_name is rename_table and :table_name configuration is set explicitly"
  end

  class TargetArgsMethod < Base
    desc 'target_arguments method'

    should "substitute source table_name for target table_name"
    # TODO: Figure out how to make this know the correct table names
    should "substitute arg[1] for target table_name on rename_table method"
  end

  class RunBangMethod < Base
    desc 'run! method'

    should "accept callable argument to run on"
    should "call the method with (method_name, target_args, block)"
  end

end

