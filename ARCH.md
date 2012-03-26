# Undestroy Model Structure

This is the basic class structure of this gem.  It was designed to be
modular and easy to tailor to your specific needs.

### `Config`

Holds configuration information for Undestroy.  An instance is created
globally and serves as defaults for each model using Undestroy, but each
model has its own unique configuration allowing developer flexibility.

Each of the core classes `Archive`, `Restore`, and `Transfer` can be
configured in the `:internals` hash option on a per model basis allowing
the developer to provide custom classes for the various actions
Undestroy provides.


### `Archive`

Map the source model's schema to the target model's and initiate the
transfer through `Transfer`.  When `run` is called the Transfer is
initialized with a primitive hash mapping the schema to the archive
table.

Initialized with:

* `:config`: Instance of Undestroy::Config for this model
* `:source`: Instance of the source model

### `Restore`

Map the archive model's schema to the source model's and initiate the
transfer through `Transfer` When `run` is called the `Transfer` is
initialized with a primitive hash mapping the schema from the archive
table to the source table.

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

Initialized with: *Options for `Config` class*

Attributes:

* `model`: The AR model ths instance binds
* `config`: Returns this model's config object

Methods:

* `before_destroy`: Perform the archive process
* `self.add(klass)`: Performs patch to provided klass needed for binding

