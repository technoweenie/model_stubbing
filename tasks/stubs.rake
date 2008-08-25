namespace :stubs do
  desc "Load a ModelStubbing definition into the database. Specify Stub file with STUBS= and Definition with DEF="
  task :load do
    root = File.dirname(__FILE__) + '/../../../../'
    require File.expand_path(root + "config/environment")

    begin
      require 'spec'
    rescue
      require 'rubygems'
      require 'spec'
    end
    require 'model_stubbing'

    require root + (ENV['STUBS'] || 'spec/stubs')
    
    defn = (ENV['DEF'] || 'default').intern
    ModelStubbing.definitions[defn].insert!
  end
end