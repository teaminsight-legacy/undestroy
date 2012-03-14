require 'assert'

module Undestroy::Test::Integration::ActiveRecordTest

  class Base < Assert::Context
    desc 'ActiveRecord integration'
  end

  class ActiveRecordExtension < Base
    desc 'extensions'

    should "add extensions to AR" do
      assert_respond_to :undestroy_model_binding, ActiveRecord::Base
    end
  end

end
