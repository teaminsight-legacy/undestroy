require 'assert'

module Undestroy::Transfer::Test

  class Base < Assert::Context
    desc 'Undestroy::Transfer class'
    subject { Undestroy::Transfer }
  end

  class BasicInstance < Base
    subject { Undestroy::Transfer.new :klass => ARFixture }
    desc 'basic instance'

    should have_accessors :target
  end

  class InitMethod < Base
    desc 'init method'

    setup do
      @fields = {
        :id => 123,
        :name => "Foo",
        :description => "Foo Description"
      }
      @transfer = subject.new :klass => ARFixture, :fields => @fields
    end

    should "raise ArgumentError if no :klass key" do
      assert_raises(ArgumentError) { subject.new }
    end

    should "default :fields to empty hash" do
      assert_not_raises { subject.new :klass => ARFixture }
    end

    should "create :klass instance with :fields" do
      assert_instance_of ARFixture, @transfer.target
      assert_equal @fields[:id], @transfer.target[:id]
      assert_equal @fields[:name], @transfer.target[:name]
      assert_equal @fields[:description], @transfer.target[:description]
    end

  end

  class RunMethod < Base
    desc 'run method'

    setup do
      @fields = {
        :id => 1,
        :name => "Bar",
        :a_field => "some_thing"
      }
      @transfer = subject.new :klass => ARFixture, :fields => @fields
    end

    should "call save on built record" do
      @transfer.run
      self.assert @transfer.target.saved?
    end
  end

end

