require 'assert'

module Undestroy::Binding::ActiveRecord::MigrationStatement::Test

  class Base < Undestroy::Test::Base
    desc 'Binding::ActiveRecord::MigrationStatement class'
    subject { @subject_class }

    setup do
      @subject_class = Undestroy::Binding::ActiveRecord::MigrationStatement
    end

  end

  class BasicInstance < Base
    desc 'basic instance'
    subject { @subject_class.new :foo }

    should have_accessor :method_name, :arguments, :block
  end

  class InitMethod < Base
    desc 'init method'

    should "set required arg1 to method_name attr" do
      obj = subject.new :method
      assert_equal :method, obj.method_name
    end

    should "set remaining args to arguments attr as Array" do
      obj = subject.new :method, :arg1, 'arg2', 3, :four => :val1, :five => :val2
      assert_equal [:arg1, 'arg2', 3, { :four => :val1, :five => :val2 }], obj.arguments
    end

    should "set optional block to block attr" do
      block = proc { "FOOO" }
      obj = subject.new :method, &block
      assert_equal block, obj.block
      assert_equal "FOOO", obj.block.call
    end
  end

end

