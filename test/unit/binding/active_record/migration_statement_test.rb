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

  class AddClassMethod < Base
    desc 'add class method'

    setup do
      @klass = Class.new do
        @@method_missing_calls = []

        def method_missing(*args, &block)
          @@method_missing_calls << [args, block]
        end

        def self.method_missing_calls
          @@method_missing_calls
        end
      end
    end

    should "add method method_missing_with_undestroy" do
      subject.add(@klass)
      assert_respond_to :method_missing_with_undestroy, @klass.new
    end

    should "alias original method_missing as method_missing_without_undestroy" do
      subject.add(@klass)
      assert @klass.new.method(:method_missing_without_undestroy)
    end

    should "always call original method_missing" do
      subject.add(@klass)
      @klass.new.foo(:bar) { }
      assert_equal 1, @klass.method_missing_calls.size
      assert_equal [:foo, :bar], @klass.method_missing_calls[0].first
      assert_instance_of Proc, @klass.method_missing_calls[0].last
    end

    should "always create an instance of MethodStatement and call run! if run?" do
      @source_class.table_name = 'source'
      @source_class.undestroy
      subject.add(@klass)
      @klass.new.add_column :source, :foo, :string
      assert_equal 2, @klass.method_missing_calls.size
      assert_equal [:add_column, 'archive_source', :foo, :string], @klass.method_missing_calls[1].first
    end
  end

  class InitMethod < Base
    desc 'init method'
    include Undestroy::Test::Helpers::ModelLoading

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

    should "call load_models on all Config.config.model_paths if not loaded yet" do
      path = Undestroy::Test.fixtures_path('load_test', 'models2')
      Undestroy::Config.config.model_paths = [path]
      assert_loads_models(path) do
        subject.new :method
      end
      Undestroy::Config.config.model_paths = []
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

    should "return true if :index is configured and index_action? is true" do
      @source_class.table_name = 'bar'
      @source_class.undestroy :indexes => true
      obj = subject.new :add_index, :bar
      assert obj.index_action?
      assert obj.run?
    end

    should "return false if :index is configured and index_action? is false" do
      @source_class.table_name = 'bar'
      @source_class.undestroy :indexes => true
      obj = subject.new :method, :bar
      assert_not obj.index_action?
      assert_not obj.run?
    end

    should "return false if :index is not configured for this table" do
      @source_class.table_name = 'bar'
      @source_class.undestroy
      obj = subject.new :add_index, :bar
      assert obj.index_action?
      assert_not obj.run?
    end

    # We will not rename a table that has been configured to a specific name
    should "return false if :method_name is rename_table and :table_name configuration is set explicitly" do
      @source_class.table_name = 'bar'
      @source_class.undestroy :table_name => 'old_bar'
      obj = subject.new :rename_table, :bar, :baz
      assert_not obj.run?
    end
  end

  class TargetArgsMethod < Base
    desc 'target_arguments method'

    setup do
      @source_class.table_name = 'source'
      @source_class.undestroy
    end

    should "leave original arguments alone" do
      obj = subject.new :add_column, :source, :foo, :string
      args = obj.arguments.dup
      obj.target_arguments
      assert_equal args, obj.arguments
    end

    should "substitute source table_name for target table_name" do
      obj = subject.new :add_column, :source, :foo, :string
      assert_equal ['archive_source', :foo, :string], obj.target_arguments
    end

    should "substitute arg[1] for target table_name on rename_table method" do
      obj = subject.new :rename_table, :source, :new_source
      assert_equal ['archive_source', 'archive_new_source'], obj.target_arguments
    end
  end

  class RunBangMethod < Base
    desc 'run! method'

    setup do
      @source_class.table_name = 'source'
      @source_class.undestroy
    end

    should "accept callable argument to run on and call with (method_name, target_args, block)" do
      called = false
      callable = proc { |*args, &block| called = [args, block] }
      block = proc { }
      obj = subject.new :add_column, :source, :foo, :string, &block
      obj.run!(callable)
      assert_equal [obj.method_name, obj.target_arguments, block].flatten, called.flatten
    end

    should "run additional add_column calls for all config.fields on :create_table method" do
      config.add_field :deleted_by_id, :integer, 1
      calls = []
      callable = proc { |*args, &block| calls << [args, block] }
      obj = subject.new :create_table, :source
      obj.run!(callable)
      assert_equal 3, calls.size
      assert_equal [:create_table, 'archive_source', nil], calls[0].flatten
      assert_equal [:add_column, 'archive_source', :deleted_at, :datetime, nil], calls[1].flatten
      assert_equal [:add_column, 'archive_source', :deleted_by_id, :integer, nil], calls[2].flatten
    end

  end

end

