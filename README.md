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

This method can also accept an options hash to further customize
Undestroy to your needs.

* `:table_name`:  use this table for archiving (Defaults to the
  source class's table_name prefixed with "archive_").
* `:abstract_class`:  use this as the base class for the target_class
  specify an alternate for custom extensions / DB connections (defaults
  to ActiveRecord::Base)
* `:fields`:  Specify a hash of fields to values for additional fields
  you would like to include on the archive table -- lambdas will be
  called with the instance being destroyed and returned value will be
  used (default: `{ :deleted_at => proc { |instance| Time.now } }`).
* `:migrate`:  Should Undestroy migrate the archive table together with
  this model's table (default: true)

Internal Options (for advanced users):

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
  config.fields = {
    :deleted_at => proc { Time.now },
    :deleted_by_id => proc { User.current.id if User.current }
  }
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

