$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'ruby-debug'
require 'active_reload/fixture_mocking'
begin
  require 'active_support'
rescue LoadError
  "No ActiveSupport gem"
end

class FakeTester
end

class BlankModel
  attr_reader :attributes
  
  def id
    nil
  end
  
  def initialize(attributes = {})
    @attributes = attributes
    attributes.each do |key, value|
      meta = class << self; self end
      meta.send :attr_accessor, key
      send "#{key}=", value
    end
  end
  
  def ==(other_model)
    self.class == other_model.class && id == other_model.id
  end
  
  def inspect
    "#{self.class.name} ##{id} => #{@attributes.inspect}"
  end
end

User = Class.new BlankModel
Post = Class.new BlankModel

define_fixtures do
  time 2007, 6, 1
  
  table :users do
    fixture :name => 'bob', :admin => false
    fixture :admin, :admin => true # inherits from default fixture
  end
  
  table :posts do
    # uses admin user fixture above
    fixture :title => 'initial', :user => all_fixtures(:admin_user), :published_at => current_time + 5.days
  end
end

ActiveReload::FixtureMocking.definitions[:default].setup_on FakeTester

Debugger.start