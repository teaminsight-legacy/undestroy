require 'undestroy'

ActiveRecord::Base.configurations = {
  'main' => {
    :adapter => 'sqlite3',
    :database => 'tmp/main.db'
  },
  'alt' => {
    :adapter => 'sqlite3',
    :database => 'tmp/alt.db'
  },
}

module Undestroy::Test

  class Base < Assert::Context

    teardown_once do
      `rm -f tmp/*.db`
    end

  end

  ActiveRecord::Base.establish_connection 'main'
  class ARMain < ActiveRecord::Base
    self.abstract_class = true
  end

  class ARAlt < ActiveRecord::Base
    self.abstract_class = true
    establish_connection 'alt'
  end

  module Integration
  end

  module Fixtures
    autoload :ActiveRecordModels, 'test/fixtures/active_record_models'
    autoload :ARFixture, 'test/fixtures/ar'
    autoload :Archive, 'test/fixtures/archive'
  end
end

