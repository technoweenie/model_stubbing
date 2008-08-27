$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "test/unit"
require 'rubygems'
require 'ruby-debug'
require 'model_stubbing'
begin
  require 'active_support'
rescue LoadError
  puts $!.to_s
end

module ModelStubbing
  class FakeTester < Test::Unit::TestCase
    def test_booya
      assert true
    end
  end
  
  class FakeConnection
    def quote_column_name(name)
      "`#{name}`"
    end
    
    def quote(value, whatever)
      value.to_s.inspect
    end
  end
  
  class BlankModel
    attr_accessor :id, :valid
    attr_reader :attributes
  
    def self.base_class
      self
    end
  
    def new_record?() @new_record end

    def valid?
      !!@valid
    end

    def initialize(attributes = {})
      @attributes = attributes
      attributes.each do |key, value|
        set_attribute key, value
      end
    end
    
    def []=(key, value)
      set_attribute key, value
    end
    
    def ==(other_model)
      self.class == other_model.class && id == other_model.id
    end
    
    def inspect
      "#{self.class.name} ##{id} => #{@attributes.inspect}"
    end
    
    def save
      @new_record = false
      self.id = db_id if self.id.nil?
    end

    def save!
      raise "Invalid!" unless valid?
      save
    end
    
    def method_missing(name, *args)
      if name.to_s =~ /(\w+)=$/
        set_attribute($1, args[0])
      else
        super
      end
    end

    def errors
      @errors ||= {}.instance_eval do
        def full_messages
          inject([]) do |msg, (key, value)|
            msg << "#{key} #{value}"
          end
        end
        self
      end
    end

  private
    def meta_class
      @meta_class ||= class << self; self end
    end
  
    def set_attribute(key, value)
      meta_class.send :attr_accessor, key
      send "#{key}=", value
      attributes[key] = value
    end
    
    @@db_id = 0
    def db_id
      @@db_id += 1
    end
  end
  
  User = Class.new BlankModel
  Post = Class.new BlankModel
  Tag  = Class.new BlankModel
  module Foo
    Bar = Class.new BlankModel
  end

  def User.table_name
    "users"
  end

  define_models do
    time 2007, 6, 1
    
    model User do
      stub :name => 'bob', :admin => false
    end
    
    model Foo::Bar do
      stub :blah => 'foo'
    end
  end

  define_models do
    model Tag do
      stub :foo, :name => "foo"
      stub :bar, :name => "bar"
    end
    
    model User do
      stub :admin, :admin => true # inherits from default fixture
    end
    
    model Post do
      # uses admin user fixture above
      stub :title => 'initial', :user => all_stubs(:admin_model_stubbing_user), :published_at => current_time + 5.days
      stub :nice_one, :title => 'nice one', :tags => [all_stubs(:foo_model_stubbing_tag), all_stubs(:bar_model_stubbing_tag)]
    end
  end
  
  definitions[:default].setup_on FakeTester
end

Debugger.start