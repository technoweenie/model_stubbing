require 'active_reload/fixture_mocking/definition'
require 'active_reload/fixture_mocking/table'
require 'active_reload/fixture_mocking/fixture'

module ActiveReload
  module FixtureMocking
    def self.definitions() @definitions ||= {} end
  end
end

def define_fixtures(name = nil, &block)
  ActiveReload::FixtureMocking.definitions[name || :default] = ActiveReload::FixtureMocking::Definition.new(&block)
end