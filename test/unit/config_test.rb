require 'assert'

class Undestroy::Config::Test

  class Base < Assert::Context
    desc 'Undestroy::Config class'
    subject { Undestroy::Config }

    teardown do
      Undestroy::Config.instance_variable_set(:@config, nil)
    end
  end

  class ConfigureClassMethod < Base
    desc 'configure class method'

    should "exist" do
      assert subject.respond_to?(:configure)
    end

    should "call the block with an instance of Config" do
      called = false
      subject.configure do |object|
        called = true
        assert_instance_of subject, object
      end
      assert called, "Block was not called"
    end

    should "store result in global config" do
      subject.configure do |object|
        object.table_name = "FOO"
      end
      config = subject.instance_variable_get(:@config)
      assert config
      assert_equal "FOO", config.table_name
    end
  end

  class ConfigClassMethod < Base
    desc 'return the global Config'

    should "exist" do
      assert subject.respond_to?(:config)
    end

    should "return Config object" do
      assert_instance_of subject, subject.config
    end

    should "return the same Config object" do
      assert_equal subject.config.object_id, subject.config.object_id
    end
  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { Undestroy::Config.new }

    should have_accessors :table_name, :connection, :fields, :migrate
    should have_accessors :source_class, :target_class, :internals
  end

  class InitMethod < Base
    desc 'init method'

    should "default migrate to true" do
      config = subject.new
      assert config.migrate
    end

    should "default fields to delayed deleted_at" do
      config = subject.new
      assert_equal [:deleted_at], config.fields.keys
      assert_instance_of Proc, config.fields[:deleted_at]
      assert_instance_of Time, config.fields[:deleted_at].call
      assert Time.now - config.fields[:deleted_at].call < 1
    end

    should "default internals to internal classes" do
      config = subject.new
      assert config.internals
      assert_instance_of Hash, config.internals
      assert_equal Undestroy::Archive, config.internals[:archive]
      assert_equal Undestroy::Transfer, config.internals[:transfer]
    end

    should "set config options using provided hash" do
      config = subject.new :table_name => "foo",
        :connection => "test_archive",
        :target_class => "foo",
        :fields => {},
        :migrate => false

      assert_equal "foo", config.table_name
      assert_equal "foo", config.target_class
      assert_equal "test_archive", config.connection
      assert_equal Hash.new, config.fields
      assert_equal false, config.migrate
    end

  end

  class MergeMethod < Base
    desc 'merge method'

    should "accept config option and return merged config options" do
      config1 = subject.new :connection => 'foo', :migrate => false
      config2 = subject.new :connection => 'bar', :fields => {}, :internals => {}
      config3 = config1.merge(config2)

      assert_equal 'bar', config3.connection
      assert_equal true, config3.migrate
      assert_equal Hash.new, config3.fields
      assert_equal Hash.new, config3.internals
      assert_equal 'foo', config1.connection
    end
  end


  class PrimitiveFields < Base
    desc 'primitive_fields method'
    subject { @config ||= Undestroy::Config.new }

    should "exist" do
      assert_respond_to :primitive_fields, subject
    end

    should "require 1 parameter" do
      assert_equal 1, subject.method(:primitive_fields).arity
    end

    should "return fields with any procs evaled" do
      assert_instance_of Hash, subject.primitive_fields(1)
      assert_instance_of Time, subject.primitive_fields(1)[:deleted_at]
    end

    should "pass argument in to proc" do
      val = {}
      subject.fields = { :test => proc { |arg| val[:arg] = arg } }
      subject.primitive_fields("FOOO!")
      assert_equal "FOOO!", val[:arg]
    end
  end

end
