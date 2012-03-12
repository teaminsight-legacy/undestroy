require 'assert'

class Undestroy::Config::BaseTest < Assert::Context
  subject { Undestroy::Config.new }
  desc 'Undestroy::Config class'

  should have_accessor :archive_table, :archive_klass, :archive_connection, :fields, :migrate

end

class Undestroy::Config::InitTest < Undestroy::Config::BaseTest
  subject { Undestroy::Config }
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

class Undestroy::Config::MergeMethodTest < Undestroy::Config::BaseTest
  subject { Undestroy::Config }
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

