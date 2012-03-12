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

To activate Undestroy on a model, simply call the `undestroyable` method
on the class like so:

    class Person < ActiveRecord::Base
      undestroyable
    end

This method also can accept an options hash to further customize
Undestroy to your needs.

* `:table_name`:  use this table for archiving
* `:class_name`:  use this AR model for archiving
* `:connection`:  use this connection for archiving
* `:fields`:  Specify a hash of fields to values for additional fields
  you would like to include on the archive table -- lambdas will be
  called with the instance being destroyed and returned value will be
  used (default: `{ :deleted_at => proc { |instance| Time.now } }`).
* `:migrate`:  Should Undestroy migrate the archive table together with
  this model's table (default: true)

    $ person = Person.find(1)
    $ person.destroy
    # => Inserts person data into archive_people table
    # => Deletes person data from people table

## Stucture

This is the basic class structure of this gem.  It was designed to be
modular and easy to tailor to your specific needs.

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

