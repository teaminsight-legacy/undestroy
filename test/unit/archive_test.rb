require 'assert'

module Undestroy::Archive::Test
  class Base < Assert::Context
    subject { Undestroy::Archive.new }
    desc 'Undestroy::Archive class'

  end
end

