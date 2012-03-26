# Undestroy

Provides automatic archiving of ActiveRecord models before the object is
destroyed.  It is designed to be database agnostic and easy to extend
with custom functionality.  Migrations will be run in parallel on the
archive table when run on the original table.  Additional archive schema
can be appended to the archive table for storing tracking data (default:
deleted_at).


## Installation

Add this line to your application's Gemfile:

    gem 'undestroy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install undestroy

You can also tell Undestroy to not extend ActiveRecord when required by
using this line in your Gemfile instead:

    gem 'undestroy', :require => 'undestroy/without_binding'

If you do this you must call
`Undestroy::Binding::ActiveRecord.add(MyARSubclass)` where
`MYARSubclass` is the class you want Undestroy to extend instead.

## Usage

To activate Undestroy on a model, simply call the `undestroy` method
on the class like so:

```ruby
class Person < ActiveRecord::Base
  undestroy
end
```

This method can also accept an options hash or block to further
customize Undestroy to your needs.  Here are some of the common options:

* `:table_name`:  use this table for archiving (Defaults to the
  source class's table_name prefixed with the :prefix option).
* `:prefix`: use this prefix for table names -- if :table_name is set
  this option does nothing (default: "archive_")
* `:abstract_class`:  use this as the base class for the target_class
  specify an alternate for custom extensions (defaults to
  ActiveRecord::Base)
* `:migrate`:  Determines whether Undestroy will handle automatic
  migrations (default: true)
* `:indexes`: When :migrate is true should indexes be migrated as well?
  (default: false) 
* `add_field(name, type, value=nil, &block)`:  method on the Config
  object that configures a new field for the archive table.  The return
  value of the block or value of `value` is used as the value of the 
  field.  The block will be passed the instance of the object to be
  archived as an argument.

You can also use a block to handle the configuration:

```ruby
class Post < ActiveRecord::Base
  undestroy do |config|
    config.prefix = "old_"
    config.add_field :deleted_by_id, :integer do |instance|
      User.current.id if User.current
    end
  end
end
```

Advanced Options:

* `:fields`:  Specify a hash of Field objects describing additional
  fields you would like to include on the archive table.  The preferred
  method of specificying fields is through the add_field method with the
  block configuration method.  (defaults to deleted_at timestamp).
* `:model_paths`: Array of paths where Undestroy models live.  This is
  used to autoload models before migrations are run (default:
  `Rails.root.join('app', 'models')`).
* `:source_class`:  the AR model of the originating data.  Set
  automatically to class `undestroy` method is called on.
* `:target_class`:  use this AR model for archiving.  Set automatically
  to dynamically generated class based on `archive_*` options.
* `internals`: internal classes to use for archival process.  Possible
  keys are `:archive`, `:transfer` and `:restore`.  Defaults to
  corresponding internal classes.  Customize to your heart's content.

```ruby
person = Person.create(:name => "Billy Mcgeeferson")
# Creates a new person record in people table
person.destroy
# => Inserts record in archive_people table
# => Deletes record from people table
People.restore(person.id)
People.archived.where(:name => "Billy Mcgeeferson").restore_all
# => Two ways to restore the record back to the people table
People.archived.find(person.id).restore_copy
# => Restores the record, but doesn't remove the archived record
People.find(person.id).destroy!
# => Destroys the record without archiving
```

## Configuring

You can specify custom global configurations for Undestroy through a
configuration block in your application initializer:

```ruby
Undestroy::Config.configure do |config|
  config.abstract_class = ArchiveModelBase
  config.add_field :deleted_by_id, :datetime do |instance|
    User.current.id if User.current
  end
end
```

Options set in this block will be the default for all models with
undestroy activated.  They can be overriden with options passed to the
`undestroy` method

## Architecture

Checkout the ARCH.md file for docs on how the gem is setup internally,
or just read the code.  My goal was to make it easy to understand and
extend.

Enjoy!

## Acknowledgements

* acts_as_archive author Winton Welsh for inspiration

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

