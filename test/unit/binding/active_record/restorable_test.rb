require 'assert'

module Undestroy::Binding::ActiveRecord::Restorable::Test

  class Base < Undestroy::Test::Base
    desc 'Binding::ActiveRecord::Restorable module'
    subject { Undestroy::Binding::ActiveRecord::Restorable }

    setup do
      @ar = Undestroy::Test::ARMain
      @receiver = Class.new(@ar) do
        cattr_accessor :calls
        self.calls = []

        def destroy
          calls << [:destroy]
          self.freeze
        end
      end
      @receiver.table_name = "foobar"
      @receiver.class_attribute :undestroy_model_binding, :instance_writer => false
      @receiver.undestroy_model_binding = Undestroy::Binding::ActiveRecord.new(@receiver)
      @receiver.connection.create_table :foobar do |t|
        t.string :name
      end

      @restore = Class.new do
        cattr_accessor :calls
        self.calls = []
        def initialize(*args)
          calls << [:init, args]
        end
        def run
          calls << [:run]
        end
      end
      @receiver.undestroy_model_binding.config.internals[:restore] = @restore
    end

    teardown do
      @receiver.connection.drop_table :foobar
    end

    def assert_ran_restore(object)
      assert_equal [:init, [{ :target => object, :config => @receiver.undestroy_model_binding.config }]],
                    @restore.calls[0]
      assert_equal [:run], @restore.calls[1]
      assert_equal 2, @restore.calls.size

    end
  end

  class RestoreBaseMethods < Base
    desc 'restore and restore__copy methods'

    setup do
      @receiver.send :include, subject
    end

    should "be instance methods" do
      assert_respond_to :restore_copy, @receiver.new
      assert_respond_to :restore, @receiver.new
    end

    should "create a config[:restore] instance passing self and the binding's config and call run on restore_copy" do
      object = @receiver.new
      object.restore_copy

      assert_ran_restore(object)

      # No Destroy
      assert_equal 0, @receiver.calls.size
    end

    should "run restore_copy and then destroy when restore called" do
      object = @receiver.new
      object.restore

      assert_ran_restore(object)

      assert_equal [:destroy], @receiver.calls[0]
    end
  end

  class RestoreRelationMethods < Base
    desc 'restore_all method for relation'

    setup do
      @receiver.send :include, subject
    end

    should "include RelationExtensions on the singleton_class for @relation" do
      assert_respond_to :restore_all, @receiver.send(:relation)
      assert_includes subject::RelationExtensions, @receiver.send(:relation).singleton_class.ancestors
    end

    should "call restore on all items in the query" do
      query = [@receiver.new, @receiver.new, @receiver.new]
      relation = @receiver.send(:relation)
      relation.instance_variable_set(:@records, query)
      relation.instance_variable_set(:@loaded, true)
      relation.restore_all
      assert_equal [[:destroy], [:destroy], [:destroy]], @receiver.calls
    end

    should "reset the relation" do
      relation = @receiver.send(:relation)
      relation.instance_variable_set(:@records, [@receiver.new])
      relation.instance_variable_set(:@loaded, true)
      relation.restore_all
      assert_equal [], relation.instance_variable_get(:@records)
    end

    should "return an array of restored records" do
      records = [@receiver.new]
      relation = @receiver.send(:relation)
      relation.instance_variable_set(:@records, records)
      relation.instance_variable_set(:@loaded, true)
      assert_equal records, relation.restore_all
    end

    should "not be visible on other Relation instances" do
      model = Class.new(@ar)
      model.table_name = 'test'
      @ar.connection.create_table :test
      assert_not_respond_to :restore_all, model.send(:relation)
      @ar.connection.drop_table :test
    end
  end

end

