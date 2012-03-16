# Undestroy

Allow copying records to alternate table before destroying an
ActiveRecord model for archiving purposes.  Data will be mapped
one-to-one to the archive table schema.  Additional fields can also be
configured for additional tracking information.  -Archive table schema
will automatically be updated when the parent model's table is migrated
through Rails.- (not yet)

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
  source class's table_name prefixed with "archive_").
* `:abstract_class`:  use this as the base class for the target_class
  specify an alternate for custom extensions / DB connections (defaults
  to ActiveRecord::Base)
* `:migrate`:  Should Undestroy migrate the archive table together with
  this model's table (default: true)

You can also use a block to handle the configuration:

```ruby
class Person < ActiveRecord::Base
  undestroy do |config|
    config.table_name "old_people"
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
* `:source_class`:  the AR model of the originating data.  Set
  automatically to class `undestroy` method is called on.
* `:target_class`:  use this AR model for archiving.  Set automatically
  to dynamically generated class based on `archive_*` options.
* `internals`: internal classes to use for archival process.  Possible
  keys are `:archive`, `:transfer` and `:restore`.  Defaults to
  corresponding internal classes.  Customize to your heart's content.

```
$ person = Person.find(1)
$ person.destroy
# => Inserts person data into archive_people table
# => Deletes person data from people table
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

