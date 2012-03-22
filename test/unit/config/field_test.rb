require 'assert'

class Undestroy::Config::Field::Test

  class Base < Undestroy::Test::Base
    desc 'Undestroy::Config::Field class'
    subject { @subject_class }

    setup do
      @subject_class = Undestroy::Config::Field
    end
  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { @subject_class.new :foo, :foo, 'foo' }

    should have_accessors(:name, :type, :raw_value)

  end

  class InitMethod < Base
    desc 'initialize method'

    should "have 2 required params" do
      assert_raises(ArgumentError) { subject.new }
      assert_not_raises { subject.new :foo, :bar, 'val' }
      assert_not_raises { subject.new(:foo, :bar) { 'val' } }
    end

    should "store name in name attr" do
      obj = subject.new :field, :string, 'val'
      assert_equal :field, obj.name
    end

    should "store type in type attr" do
      obj = subject.new :field, :string, 'val'
      assert_equal :string, obj.type
    end

    should "store value in raw_value attr if present" do
      obj = subject.new :field, :string, 'val'
      assert_equal 'val', obj.raw_value
    end

    should "store optional block in raw_value" do
      block = proc { "foo" }
      obj = subject.new :field, :string, 'val', &block
      assert_equal block, obj.raw_value
    end

    should "raise if a block and a value are not passed" do
      assert_raises(ArgumentError) { subject.new :field, :string }
    end
  end

  class ValueMethod < Base
    desc 'value method'

    should "return raw_value if not callable" do
      obj = subject.new :field, :string, 'val'
      assert_equal 'val', obj.value
    end

    should "evaluate raw_value with passed args" do
      block = proc { |args| args }
      block2 = proc { |arg1, arg2| [arg1, arg2] }
      obj = subject.new :field, :string, &block
      obj2 = subject.new :field, :string, &block2
      assert_equal 1, obj.value(1)
      assert_equal [1, 2], obj2.value(1, 2)
    end
  end

  class SortOperator < Base
    desc 'sort operator'

    should "sort by alphanumeric field name" do
      names = ["orange", :apple, "banana", "orange2"]
      fields = names.collect { |name| Undestroy::Config::Field.new(name, :type, 'val') }
      assert_equal names.collect(&:to_s).sort, fields.sort.collect { |f| f.name.to_s }
    end
  end

end

