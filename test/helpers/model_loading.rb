module Undestroy::Test::Helpers::ModelLoading

  def assert_loads_models(path, &block)
    require 'active_support/dependencies'
    ActiveSupport::Dependencies.hook!
    ActiveSupport::Dependencies.autoload_paths += [path]

    block.call

    assert defined?(TestModel001), "TestModel001 did not load"
    assert defined?(TestModel002), "TestModel002 did not load"
    assert defined?(TestModule001), "TestModule001 did not load"
    assert defined?(TestModule001::TestModel003), "Testmodule001::TestModel003 did not load"
  ensure
    ActiveSupport::Dependencies.autoload_paths -= [path]
    ActiveSupport::Dependencies.remove_unloadable_constants!
    ActiveSupport::Dependencies.unhook!
  end

end
