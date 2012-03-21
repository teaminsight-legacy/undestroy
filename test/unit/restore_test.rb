require 'assert'

module Undestroy::Restore::Test

  class Base < Undestroy::Test::Base
    desc 'Undestroy::Restore class'
    subject { @subject_klass }

    setup do
      @source_class = Class.new(Undestroy::Test::Fixtures::ARFixture)
      @target_class = Class.new(Undestroy::Test::Fixtures::ARFixture)
      @subject_klass = Undestroy::Restore
      @default_init = {
        :target => @target_class.construct(:id => 1, :name => "Foo", :deleted_at => Time.now),
        :config => Undestroy::Config.new(
          :source_class => @source_class,
          :target_class => @target_class
        )
      }
    end
  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { @restore ||= @subject_klass.new @default_init }

    should have_accessors :target, :config, :transfer
  end

  class InitMethod < Base
    desc 'init method'

    should "accept hash of arguments and set them to attributes" do
      restore = subject.new :target => 1, :config => 2, :transfer => 3
      assert_equal 1, restore.target
      assert_equal 2, restore.config
      assert_equal 3, restore.transfer
    end

    should "require :target and :config keys" do
      assert_raises(ArgumentError) { subject.new :transfer => :foo }
      assert_raises(ArgumentError) { subject.new :target => :foo }
      assert_raises(ArgumentError) { subject.new :config => :foo }
    end
  end

  class TransferMethod < BasicInstance
    desc 'transfer method'

    should "return instance of config.internals[:transfer]" do
      assert_instance_of @default_init[:config].internals[:transfer], subject.transfer
    end

    should ":klass should be config.source_class" do
      assert_instance_of @default_init[:config].source_class, subject.transfer.target
    end

    should ":fields should be target.attributes - config.fields.keys" do
      assert_equal({ :id => 1, :name => "Foo" }, subject.transfer.target.attributes)
    end

    should "cache transfer object" do
      assert_equal subject.transfer.object_id, subject.transfer.object_id
    end
  end

  class RunMethod < BasicInstance
    desc 'run method'

    should "call run on the transfer" do
      foo = Class.new do
        @@called = false
        def initialize(options={})
        end

        def run
          @@called = true
        end

        def self.called
          @@called
        end
      end

      subject.transfer = foo.new
      subject.run
      assert foo.called, "Foo was not called"
    end
  end

end

