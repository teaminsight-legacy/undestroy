require 'assert'

module Undestroy::Binding::ActiveRecord::Test

  class Base < Assert::Context
    desc 'Binding::ActiveRecord class'
    subject { Undestroy::Binding::ActiveRecord }

    setup do
      ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'tmp/test.db'
      @model = Class.new(ActiveRecord::Base)
      @model.table_name = 'foobar'
      @model.connection.create_table :foobar, :force => true
    end

    teardown do
      @model.connection.execute 'drop table if exists foobar'
      Undestroy::Config.instance_variable_set(:@config, nil)
      ActiveRecord::Base.configurations = {}
      ActiveRecord::Base.clear_active_connections!
      Undestroy::Test::Fixtures::Archive.reset
    end
  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { Undestroy::Binding::ActiveRecord.new @model }

    should have_accessors :config, :model
  end

  class AddClassMethod < Base
    desc 'add class method'

    setup do
      @model.class_eval do
        undef_method :undestroy_model_binding if respond_to?(:undestroy_model_binding)
        remove_possible_method :undestroy_model_binding=
        class << self
          undef_method :undestroy_model_binding
          undef_method :undestroy
        end
      end
      @model._destroy_callbacks = []
    end

    should "add class_attr called `undestroy_model_binding`" do
      subject.add @model
      assert_respond_to :undestroy_model_binding, @model
      assert_respond_to :undestroy_model_binding=, @model
    end

    should "add undestroy class method to AR::Base initializing this binding" do
      subject.add @model
      assert_respond_to :undestroy, @model

      @model.undestroy :fields => {}

      assert_instance_of subject, @model.undestroy_model_binding
      assert_equal Hash.new, @model.undestroy_model_binding.config.fields
    end

    should "add before_destroy callback calling `before_destroy` on class_attr value" do
      subject.add @model
      archive_class = Undestroy::Test::Fixtures::Archive
      @model.undestroy_model_binding = subject.new(
        @model,
        :internals => { :archive => archive_class }
      )
      callback = @model._destroy_callbacks.first
      assert callback, "No destroy callbacks defined"
      assert_equal :before, callback.kind
      assert_instance_of Proc, callback.raw_filter

      instance = @model.new
      instance.instance_eval(&callback.raw_filter)
      assert_equal [[:run]], archive_class.data[:calls]
    end

    should "only add once" do
      subject.add @model
      subject.add @model
      assert_equal 1, @model._destroy_callbacks.size
    end

    should "allow adding to other classes" do
      new_model = Class.new(@model)
      subject.add(new_model)
      assert_respond_to :undestroy_model_binding, new_model
      assert_not_respond_to :undestroy_model_binding, @model
    end
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
      test_class = Undestroy::Test::Fixtures::Archive
      ar_source = Undestroy::Test::Fixtures::ARFixture.new
      subject.config.internals[:archive] = test_class
      subject.before_destroy(ar_source)

      assert_equal({ :config => subject.config, :source => ar_source }, test_class.data[:args])
      assert_equal [[:run]], test_class.data[:calls]
    end
  end

end

