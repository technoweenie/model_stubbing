require 'model_stubbing/definition'
require 'model_stubbing/model'
require 'model_stubbing/stub'

module ModelStubbing
  extend self
  def self.definitions() @definitions ||= {} end
  
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
  
  def define_models(name = nil, &block)
    defn = ModelStubbing::Definition.new(&block)
    if is_a? Class
      ModelStubbing.definitions[name || self] = defn
      defn.setup_on self
      puts ancestors.inspect
      if defined?(Test::Unit::TestCase) && ancestors.include?(Test::Unit::TestCase)
        self.send :include, TestUnitExtension
      elsif defined?(Spec::DSL::Example) && ancestors.include?(Spec::DSL::Example)
        self.send :include, RspecExtension
      end
    else
      ModelStubbing.definitions[name || :default] = defn
    end
  end
  
  module RspecExtension
    def self.included(base)
      base.prepend_before do
        ModelStubbing.stub_current_time_with(current_time) if current_time
      end
    end
  end
  
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