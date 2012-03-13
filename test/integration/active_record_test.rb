require 'assert'

module Undestroy::Test::Integration::ActiveRecordTest

  class Base < Assert::Context
    desc 'ActiveRecord integration'
  end

  class ActiveRecordExtension < Base
    desc 'class extensions'

    should "add undestroy class method to AR::Base"
    should "add before_destroy callback"
  end

  class UndestroyMethod < Base
    desc 'undestroy method'

    should "store binding in class_attr called `undestroy_model_binding`"
    should "instantiate Undestroy::Binding::AR with passed options"
  end

  class BeforeDestroyCallback < Base
    desc 'before_destroy callback'

    should "call Undestroy::Binding::AR#destroy"
  end

end
