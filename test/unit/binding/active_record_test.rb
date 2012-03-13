require 'assert'

module Undestroy::Binding::ActiveRecord::Test

  class Base < Assert::Context
    desc 'Binding::ActiveRecord class'
    subject { Undestroy::Binding::ActiveRecord }

    setup do
      ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'tmp/test.db'
      @model = Class.new(ActiveRecord::Base)
    end

    teardown do
      Undestroy::Config.instance_variable_set(:@config, nil)
      ActiveRecord::Base.configurations = {}
      ActiveRecord::Base.clear_active_connections!
    end
  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { Undestroy::Binding::ActiveRecord.new @model }

    should have_accessors :config, :model
  end

  class InitMethod < Base
    desc 'init method'

    should "require first argument and set it to model" do
      assert_raises(ArgumentError) { subject.new }
      binding = subject.new @model
      assert_equal @model, binding.model
    end

    should "validate model argument is AR::Base" do
      assert_raises(ArgumentError) { subject.new Class.new }
    end

    should "accept optional hash of config options" do
      assert_not_raises { subject.new @model, {} }
    end

    should "set config attr to new config object" do
      binding = subject.new @model
      assert_instance_of Undestroy::Config, binding.config
    end

    should "merge config options onto global config" do
      Undestroy::Config.configure do |config|
        config.fields = {}
      end
      assert_equal Hash.new, subject.new(@model).config.fields
      assert_not_equal subject.new(@model).config.object_id, Undestroy::Config.config.object_id
      assert_equal({ :foo => :bar }, subject.new(@model, :fields => { :foo => :bar }).config.fields)
    end

    should "set config.source_class to value of model" do
      binding = subject.new(@model)
      assert_equal @model, binding.config.source_class
    end

    should "default :table_name to 'archive_{source.table_name}'" do
      @model.table_name = :foobar
      binding = subject.new(@model)
      assert_equal 'archive_foobar', binding.config.table_name
    end

    should "create a target_class if none provided" do
      binding = subject.new(@model)
      assert binding.config.target_class.ancestors.include?(ActiveRecord::Base)
    end

    should "use target_class if provided" do
      target = Class.new(ActiveRecord::Base)
      target.table_name = "target_class_test"
      target.establish_connection :adapter => 'sqlite3', :database => 'tmp/target_class_test.db'
      binding = subject.new(@model, :target_class => target)

      assert_equal target, binding.config.target_class
      assert_equal 'target_class_test', binding.config.target_class.table_name
      assert_equal 'tmp/target_class_test.db', binding.config.target_class.connection_config[:database]
    end

    should "validate target_class is AR::Base if provided" do
      target = Class.new
      assert_raises(ArgumentError) { subject.new(@model, :target_class => target) }
    end

    should "set target class's table_name to :table_name attr" do
      binding = subject.new(@model, :table_name => "foo_foo_archive")
      assert_equal "foo_foo_archive", binding.config.target_class.table_name
    end

    should "set target class's connection to :connection attr" do
      @model.table_name = :foobar
      @model.configurations = {
        'archive_foobar_test' => {
          'adapter' => 'sqlite3',
          'database' => 'tmp/foobar_test.db'
        }
      }
      binding = subject.new(@model, :connection => "archive_foobar_test")
      assert_equal 'tmp/foobar_test.db', binding.config.target_class.connection_config[:database]
    end

  end

  class BeforeDestroy < Base
    desc 'before_destroy method'
    subject { @binding ||= Undestroy::Binding::ActiveRecord.new(@model) }

    should "exist and require one param" do
      assert_respond_to :before_destroy, subject
      assert_equal 1, subject.method(:before_destroy).arity
    end

    should "instantiate config[:archive] instance with config and model instance and call `run`" do
      test_class = Class.new do
        @@data = { :calls => [] }
        def initialize(args)
          @@data[:args] = args
        end

        def run
          @@data[:calls] << [:run]
        end

        def self.data
          @@data
        end
      end

      subject.config.internals[:archive] = test_class
      ar_source = Undestroy::Test::Fixtures::ARFixture.new
      subject.before_destroy(ar_source)

      assert_equal({ :config => subject.config, :source => ar_source }, test_class.data[:args])
      assert_equal [[:run]], test_class.data[:calls]
    end
  end

end

