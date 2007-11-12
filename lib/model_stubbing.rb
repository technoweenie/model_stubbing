require 'model_stubbing/definition'
require 'model_stubbing/model'
require 'model_stubbing/stub'

module ModelStubbing
  extend self
  # Gets a hash of all current definitions.
  def self.definitions() @definitions ||= {} end
  
  # Creates a new ModelStubbing::Definition.  If called from within a class,
  # it is automatically setup (See Definition#setup_on).
  #
  # Creates or updates a definition going by the given name as a key.  If
  # no name is given, it defaults to the current class or :default.  Multiple
  # #define_models calls with the same name will modify the definition.
  def define_models(name = nil, &block)
    name ||= is_a?(Class) ? self : :default
    defn = ModelStubbing.definitions[name] ||= ModelStubbing::Definition.new
    defn.instance_eval(&block)
    defn.setup_on self
  end

protected
  @@mock_framework = nil
  def self.stub_current_time_with(time)
    guess_mock_framework!
    case @@mock_framework
      when :rspec then Time.stub!(:now).and_return(time)
      when :mocha then Time.stubs(:now).returns(time)
    end
  end
  
  def self.guess_mock_framework!
    if @@mock_framework.nil?
      @@mock_framework = 
        if Time.respond_to?(:stub!)
          :rspec
        elsif Time.respond_to?(:stubs)
          :mocha
        else
          raise "Unknown mock framework."
        end
    end
  end

  # Included into the current rspec example when #define_models is called.
  module RspecExtension
    def self.included(base)
      base.prepend_before :all do
        self.class.definition.models.values.each &:insert if self.class.definition.database?
      end
      base.prepend_before do
        ModelStubbing.stub_current_time_with(current_time) if current_time
      end
    end
  end
  
  # Included into Test::Unit::TestCase when #define_models is calle.d
  module TestUnitExtension
    def self.included(base)
      base.class_eval do
        alias setup_without_model_stubbing setup
        alias setup setup_with_model_stubbing
      end
    end
    
    def setup_with_model_stubbing
      ModelStubbing.stub_current_time_with(current_time) if current_time
    end
  end
end