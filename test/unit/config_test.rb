require 'assert'

class Undestroy::Config::Test

  class Base < Undestroy::Test::Base
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

  class CatalogClassMethod < Base
    desc 'catalog class method'

    should "exist" do
      assert_respond_to :catalog, subject
    end

    should "return Array" do
      assert_kind_of Array, subject.catalog
    end

    should "persist Array" do
      assert_equal subject.catalog.object_id, subject.catalog.object_id
    end
  end

  class ResetCatalogClassMethod < Base
    desc 'reset_catalog class method'

    should "exist" do
      assert_respond_to :reset_catalog, subject
    end

    should "reset catalog cache" do
      catalog = subject.catalog
      subject.reset_catalog
      assert_not_equal catalog.object_id, subject.catalog.object_id
    end
  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { Undestroy::Config.new }

    should have_accessors :table_name, :abstract_class, :fields, :migrate, :indexes, :prefix
    should have_accessors :source_class, :target_class, :internals, :model_paths
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
      assert_instance_of Undestroy::Config::Field, config.fields[:deleted_at]
      assert_instance_of Time, config.fields[:deleted_at].value(1)
      assert Time.now - config.fields[:deleted_at].value(1)< 1
    end

    should "default internals to internal classes" do
      config = subject.new
      assert config.internals
      assert_instance_of Hash, config.internals
      assert_equal Undestroy::Archive, config.internals[:archive]
      assert_equal Undestroy::Transfer, config.internals[:transfer]
    end

    should "default indexes to false" do
      config = subject.new
      assert_equal false, config.indexes
    end

    should "default prefix to 'archive_'" do
      config = subject.new
      assert_equal 'archive_', config.prefix
    end

    should "default model_paths to [] if Rails is not defined" do
      config = subject.new
      assert_equal [], config.model_paths
    end

    should "dup passed in objects" do
      fields = {}
      config = subject.new :fields => fields
      config.add_field :foo, :bar, :baz
      assert fields.empty?
    end

    should "default model_paths to [Rails.root.join('app', 'models')] if Rails is defined" do
      module ::Rails
        @@base_root = "/foo/bar"
        def self.root
          self
        end

        def self.join(*args)
          File.join(@@base_root, *args)
        end
      end

      config = subject.new
      assert_equal ["/foo/bar/app/models"], config.model_paths
      Object.send(:remove_const, :Rails)
    end

    should "set config options using provided hash" do
      config = subject.new :table_name => "foo",
        :abstract_class => "test_archive",
        :target_class => "foo",
        :fields => {},
        :migrate => false,
        :indexes => true

      assert_equal "foo", config.table_name
      assert_equal "foo", config.target_class
      assert_equal "test_archive", config.abstract_class
      assert_equal Hash.new, config.fields
      assert_equal false, config.migrate
      assert_equal true, config.indexes
    end

    should "track instances in catalog" do
      config = subject.new
      assert_includes config, subject.catalog
    end

  end

  class MergeMethod < Base
    desc 'merge method'

    should "accept config option and return merged config options" do
      config1 = subject.new :abstract_class => 'foo', :migrate => false
      config2 = subject.new :abstract_class => 'bar', :fields => {}, :internals => {}
      config3 = config1.merge(config2)

      assert_equal 'bar', config3.abstract_class
      assert_equal true, config3.migrate
      assert_equal Hash.new, config3.fields
      assert_equal Hash.new, config3.internals
      assert_equal 'foo', config1.abstract_class
    end
  end


  class PrimitiveFieldsMethod < Base
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
      subject.fields = { :test => Undestroy::Config::Field.new(:test, :string) { |arg| val[:arg] = arg } }
      subject.primitive_fields("FOOO!")
      assert_equal "FOOO!", val[:arg]
    end
  end

  class AddFieldMethod < Base
    desc 'add_field method'
    subject { @config ||= Undestroy::Config.new }

    should "pass args to Config::Field constructor" do
      field = subject.add_field :foo, :string, 'val'
      assert_instance_of Undestroy::Config::Field, field
      assert_equal :foo, field.name
      assert_equal :string, field.type
      assert_equal 'val', field.raw_value
    end

    should "pass block to Config::Field constructor" do
      block = proc { |i| "foo" }
      field = subject.add_field :foo, :string, &block
      assert_equal block, field.raw_value
    end

    should "store new Field on fields hash" do
      field = subject.add_field :foo, :string, 'val'
      assert_equal field, subject.fields[:foo]
    end
  end

end
