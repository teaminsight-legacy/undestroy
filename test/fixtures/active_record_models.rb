module Undestroy::Test::Fixtures::ActiveRecordModels

  class Blog < Undestroy::Test::ARMain
    undestroy
    has_many :posts, :dependent => :destroy
  end

  class Post < Undestroy::Test::ARMain
    undestroy
    belongs_to :blog
  end

  def self.add_blog_tables(model)
    model.connection.create_table :blogs do |t|
      t.string :name
    end
    model.connection.create_table :archive_blogs do |t|
      t.string :name
      t.datetime :deleted_at
    end

    model.connection.create_table :posts do |t|
      t.integer :blog_id
      t.string :title
      t.text :body
    end
    model.connection.create_table :archive_posts do |t|
      t.datetime :deleted_at
      t.integer :blog_id
      t.string :title
      t.text :body
    end
  end

  def self.remove_blog_tables(model)
    model.connection.drop_table :blogs
    model.connection.drop_table :archive_blogs
    model.connection.drop_table :posts
    model.connection.drop_table :archive_posts
  end

end
