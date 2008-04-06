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
    
    # note to Rick: I've taken to using 'stubs.rb' instead of 'model_stubs.rb'
    # because 'model_stubs' has a tab-completion collision with 'spec/models' and
    # that drives me batty. Change the default to 'spec/model_stubs' if you want,
    # you won't hurt my feelings.
    require root + (ENV['STUBS'] || 'spec/stubs')
    
    defn = (ENV['DEF'] || 'default').intern
    ModelStubbing.definitions[defn].insert!
  end
  
end