# make sure we're running inside Merb
if defined?(Merb::Plugins)
  module Merb
    module Cache
      autoload :MintStore,    "mint_store" / "mint_store" 
    end
  end
end