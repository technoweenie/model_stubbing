require 'model_stubbing/extensions'
require 'model_stubbing/definition'
require 'model_stubbing/model'
require 'model_stubbing/stub'

module ModelStubbing
  extend self
  # Gets a hash of all current definitions.
  def self.definitions() @definitions ||= {} end
  # stores {stub => record_id} so that identical stubs keep the same ID
  def self.record_ids()  @record_ids  ||= {} end
  # stores {record_id => instantiated stubs}.  reset after each spec
  def self.records()     @records     ||= {} end

  # Creates a new ModelStubbing::Definition.  If called from within a class,
  # it is automatically setup (See Definition#setup_on).
  #
  # Creates or updates a definition going by the given name as a key.  If
  # no name is given, it defaults to the current class or :default.  Multiple
  # #define_models calls with the same name will modify the definition.
  # 
  # Options:
  # * :copy - set to false if you don't want this definition to be a dup of
  #   the :default definition
  # * :insert - set to false if you don't want to insert this definition
  #   into the database.
  def define_models(name = nil, options = {}, &block)
    if name.is_a? Hash
      options = name
      name    = nil
    end
    name    ||= is_a?(Class) ? self : :default
    base_name = options[:copy] || :default
    base      = name == base_name ? nil : ModelStubbing.definitions[base_name]
    defn      = ModelStubbing.definitions[name] ||= (base && options[:copy] != false) ? base.dup : ModelStubbing::Definition.new
    defn.setup_on self, options, &block
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
end

Test::Unit::TestCase.extend ModelStubbing