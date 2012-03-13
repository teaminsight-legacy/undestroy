# Undestroy

Allow copying records to alternate table before destroying an
ActiveRecord model for archiving purposes.  Data will be mapped
one-to-one to the archive table schema.  Additional fields can also be
configured for additional tracking information.  Archive table schema
will automatically be updated when the parent model's table is migrated
through Rails.

## Installation

Add this line to your application's Gemfile:

    gem 'undestroy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install undestroy

## Usage

To activate Undestroy on a model, simply call the `undestroy` method
on the class like so:

```ruby
class Person < ActiveRecord::Base
  undestroy
end
```

This method also can accept an options hash to further customize
Undestroy to your needs.

* `:archive_table`:  use this table for archiving
* `:archive_klass`:  use this AR model for archiving
* `:archive_connection`:  use this connection for archiving
* `:fields`:  Specify a hash of fields to values for additional fields
  you would like to include on the archive table -- lambdas will be
  called with the instance being destroyed and returned value will be
  used (default: `{ :deleted_at => proc { |instance| Time.now } }`).
* `:migrate`:  Should Undestroy migrate the archive table together with
  this model's table (default: true)

```
$ person = Person.find(1)
$ person.destroy
# => Inserts person data into archive_people table
# => Deletes person data from people table
```

## Model Stucture

This is the basic class structure of this gem.  It was designed to be
modular and easy to tailor to your specific needs.

### `Config`

Holds configuration information for Undestroy.  An instance is created
globally and serves as defaults for each model using Undestroy.  Each
model also creates its own instance of Config allowing any model to
override any of the globally configurable options.

To change global defaults use this configuration DSL:

```ruby
Undestroy::Config.configure do |config|
  config.connection = "#{Rails.env}_archive"
  config.fields = {
    :deleted_at => proc { Time.now },
    :deleted_by_id => proc { User.current.id if User.current }
  }
end
```

This sets the default connection to the Rails.env followed by an
"_archive".  An entry matching this format must exist in database.yml in
order for this to function properly.  This also sets the default fields
to include a deleted_by_id which automatically sets the current user as
the deleter of the record.

Possible configuration options are listed in the _Usage_ section above.

### `Archive`

Map the source model's schema to the archive model's and initiate the
transfer through `Transfer`.  When `run` is called the Transfer is
initialized with a primitive hash mapping the schema to the archive
table.

Initialized with:

* `:config`: Instance of Undestroy::Config for this model
* `:source`: Instance of the source model

### `Restore`

Map the archive model's schema to the source model's and initiate the
transfer through `Transfer`

Initialized with:

* `:config`: Instance of Undestroy::Config for this model
* `:archive`: Instance of the archived model

### `Transfer`

Handles the actual movement of data from one table to another.  This
class simply uses the AR interface to create and delete the appropriate
records.  This can be subclassed to provide enhanced performance or
customized behavior for your situation.

### The glue code

There will also be code needed to glue these abstract concepts into
ActiveRecord.  Such as hooking up migrations to auto-run, and hooking
into the destroy events.

Initialized with:

* `:fields`: Hash of field names to values to be stored in this table
* `:klass`: Target AR model which will be created with these attributes

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

