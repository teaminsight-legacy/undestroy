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
        object.archive_table = "FOO"
      end
      config = subject.instance_variable_get(:@config)
      assert config
      assert_equal "FOO", config.archive_table
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

    should have_accessor :archive_table, :archive_klass, :archive_connection, :fields, :migrate
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

    should "set config options using provided hash" do
      config = subject.new :archive_table => "foo",
        :archive_connection => "test_archive",
        :archive_klass => "foo",
        :fields => {},
        :migrate => false

      assert_equal "foo", config.archive_table
      assert_equal "foo", config.archive_klass
      assert_equal "test_archive", config.archive_connection
      assert_equal Hash.new, config.fields
      assert_equal false, config.migrate
    end

  end

  class MergeMethod < Base
    desc 'merge method'

    should "accept config option and return merged config options" do
      config1 = subject.new :archive_connection => 'foo', :migrate => false
      config2 = subject.new :archive_connection => 'bar', :fields => {}
      config3 = config1.merge(config2)

      assert_equal 'bar', config3.archive_connection
      assert_equal true, config3.migrate
      assert_equal Hash.new, config3.fields
      assert_equal 'foo', config1.archive_connection
    end
  end

end
