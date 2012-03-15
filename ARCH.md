# Undestroy Model Structure

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
  config.abstract_class = ArchiveModel
  config.fields = {
    :deleted_at => proc { Time.now },
    :deleted_by_id => proc { User.current.id if User.current }
  }
end
```

This changes the default abstract class from ActiveRecord::Base to a
model called ArchiveModel.  This also sets the default fields to include
a deleted_by_id which automatically sets the current user as the deleter
of the record.

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

Initialized with:

* `:fields`: Hash of field names to values to be stored in this table
* `:klass`: Target AR model which will be created with these attributes

### `Binding::ActiveRecord`

Binds the base functionality to ActiveRecord.  It is initialized by the
parameters to the `undestroy` class method and contains the method that
is bound to the `before_destroy` callback that performs the archiving
functions.  Any of the code that handles ActiveRecord specific logic
lives in here.

Initialized with: *Config options from above*

Attributes:

* `config`: Returns this model's config object
* `model`: The AR model this instnace was created for

Methods:

* `before_destroy`: Perform the archive process

