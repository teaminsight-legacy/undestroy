require 'assert'

module Undestroy::Binding::ActiveRecord::MigrationStatement::Test

  class Base < Undestroy::Test::Base
    desc 'Binding::ActiveRecord::MigrationStatement class'
    subject { @subject_class }

    setup do
      @subject_class = Undestroy::Binding::ActiveRecord::MigrationStatement
      @catalog = Undestroy::Config.catalog

      @source_class = Class.new(Undestroy::Test::ARMain)
    end

    def config
      @source_class.undestroy_model_binding.config
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

  class SourceTableNameMethod < Base
    desc 'source_table_name method'

    should "return arguments[0]" do
      obj = subject.new :method, 'table_name', 1
      assert_equal 'table_name', obj.source_table_name
    end
  end

  class TargetTableNameMethod < Base
    desc 'target_table_name method'

    should 'return "archive_#{original_table_name}" when :table_name config not set' do
      @source_class.table_name = 'poop'
      @source_class.undestroy
      assert_equal 'archive_poop', subject.new(:method, 'poop').target_table_name
    end

    should 'return :table_name config value when set' do
      @source_class.table_name = 'poop'
      @source_class.undestroy :table_name => 'old_poop_table'
      assert_equal 'old_poop_table', subject.new(:method, 'poop').target_table_name
    end
  end

  class ConfigMethod < Base
    desc 'config method'

    should "fetch config object for the given table name from Undestroy::Config.catalog" do
      @source_class.table_name = 'foobar'
      @source_class.undestroy
      assert_equal config, subject.new(:method, 'foobar').config
    end
  end

  class SchemaActionMethod < Base
    desc 'schema_action? method'

    should "return true if method_name is a schema modification method" do
      [
        :create_table, :drop_table, :rename_table,
        :add_column, :rename_column, :change_column, :remove_column
      ].each do |method|
        obj = subject.new method
        assert obj.schema_action?
      end
    end

    should "return false otherwise" do
      obj = subject.new :method
      assert_not obj.schema_action?
    end
  end

  class IndexActionMethod < Base
    desc 'index_action? method'

    should "return true if method_name is an index modification method" do
      [
        :add_index, :remove_index
      ].each do |method|
        obj = subject.new method
        assert obj.index_action?
      end
    end

    should "return false otherwise" do
      obj = subject.new :method
      assert_not obj.index_action?
    end
  end

  class RunQueryMethod < Base
    desc 'run? method'

    should "always return false if arguments are empty" do
      obj = subject.new :method
      assert_not obj.run?
    end

    should "always return false if no configuration is present for this *source* table name" do
      @source_class.table_name = 'bar'
      @source_class.undestroy
      obj = subject.new :method, 'foo'
      assert_not obj.run?
    end

    should "return true if :migrate is configured and schema_action? is true" do
      @source_class.table_name = 'bar'
      @source_class.undestroy
      obj = subject.new :add_column, :bar, :name, :string
      assert obj.schema_action?
      assert obj.run?
    end

    should "return false if :migrate is configured and schema_action? is false" do
      @source_class.table_name = 'bar'
      @source_class.undestroy
      obj = subject.new :method, :bar, :name, :string
      assert_not obj.run?
    end

    should "return false if :migrate not configured for this table" do
      @source_class.table_name = 'bar'
      @source_class.undestroy :migrate => false
      obj = subject.new :add_column, :bar, :name, :string
      assert obj.schema_action?
      assert_not obj.run?
    end

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

