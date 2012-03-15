require 'assert'

module Undestroy::Test::Integration::ActiveRecordTest

  class Base < Undestroy::Test::Base
    desc 'ActiveRecord integration'

    setup do
      @ar = Undestroy::Test::ARMain
    end

  end

  class ActiveRecordExtension < Base
    desc 'extensions'

    should "add extensions to AR" do
      assert_respond_to :undestroy_model_binding, ActiveRecord::Base
    end
  end

  class BasicModelWithoutUndestroy < Base
    desc 'basic model without Undestroy'

    setup do
      @ar.connection.create_table :basic_model_table do |t|
        t.string :name
      end
      @model = Class.new(@ar)
      @model.table_name = 'basic_model_table'
    end

    teardown do
      @ar.connection.drop_table :basic_model_table
    end

    should "successfully traverse the model lifecycle" do
      record = @model.create!(:name => 'bar')
      assert @model.first
      assert_not_raises { record.destroy }
    end
  end

  class BasicModel < Base
    desc 'basic model with Undestroy'

    setup do
      @ar.connection.create_table :basic_model_table do |t|
        t.string :name
      end
      @ar.connection.create_table :archive_basic_model_table do |t|
        t.string :name
        t.datetime :deleted_at
      end
      @model = Class.new(@ar)
      @model.table_name = 'basic_model_table'
    end

    teardown do
      @ar.connection.drop_table :basic_model_table
      @ar.connection.drop_table :archive_basic_model_table
    end

    should "create an archive record on destroy" do
      @model.undestroy
      target_class = @model.undestroy_model_binding.config.target_class

      @model.create(:name => "foo")
      original = @model.first
      original.destroy
      archive = target_class.first

      assert original
      assert archive
      assert_equal original.id, archive.id
      assert_equal 'foo', archive.name
      assert_kind_of Time, archive.deleted_at
      assert (Time.now - archive.deleted_at) < 1.second
      assert_equal 0, @model.all.size
    end
  end

  class DependentDestroy < Base
    desc 'model with dependent undestroy enabled models'

    setup do
      @fixtures = Undestroy::Test::Fixtures::ActiveRecordModels

      @blog = @fixtures::Blog
      @post = @fixtures::Post
      @fixtures.add_blog_tables(@blog)

      @archive_blog = @blog.undestroy_model_binding.config.target_class
      @archive_post = @post.undestroy_model_binding.config.target_class
    end

    teardown do
      @fixtures.remove_blog_tables(@blog)
    end

    should "archive orphan blog" do
      blog = @blog.create!(:name => "Foo Blog")
      assert @blog.first
      blog.destroy
      assert_not @blog.first
      assert @archive_blog.first
      assert_equal "Foo Blog", @archive_blog.first.name
    end

    should "archive post" do
      blog = @blog.create!(:name => "Bar Blog")
      post = @post.create!(:title => "Foo Post", :body => "text", :blog => blog)
      assert blog and post
      post.destroy
      archive = @archive_post.first

      assert_not @post.first
      assert archive
      assert_equal post.id, archive.id
      assert_equal "text", archive.body
      assert_equal "Foo Post", archive.title
      assert_equal blog.id, archive.blog_id
    end

    should "remove all posts and archive them when the blog is destroyed" do
      blog = @blog.create!(:name => "My Verbose Blog")
      posts = (1..10).collect do |i|
        @post.create!(:title => "Article #{i}", :body => "Some text", :blog => blog)
      end
      blog.destroy

      assert_equal 0, @blog.all.size
      assert_equal 0, @post.all.size
      assert_equal 1, @archive_blog.all.size
      assert_equal 10, @archive_post.all.size
    end
  end

end
