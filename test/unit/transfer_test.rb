require 'assert'

class Undestroy::Transfer::BaseTest < Assert::Context
  subject { Undestroy::Transfer.new :klass => ARFixture }
  desc 'Undestroy::Transfer class'

  should have_accessors :target

end

class Undestroy::Transfer::InitTest < Undestroy::Transfer::BaseTest
  subject { Undestroy::Transfer }
  'init method'

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

class Undestroy::Transfer::RunTest < Undestroy::Transfer::BaseTest
  subject { Undestroy::Transfer }
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

