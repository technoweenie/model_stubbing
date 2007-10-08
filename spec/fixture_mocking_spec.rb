dir = File.dirname(__FILE__)
require File.join(dir, 'spec_helper')
require File.join(dir, 'fixtures')

include ActiveReload
include ActiveReload::FixtureMocking
  
describe Definition do
  before :all do
    @definition = FixtureMocking.definitions[:default]
  end
  
  it "should be defined as default definition" do
    @definition.should be_kind_of(Definition)
  end
  
  it "should set #current_time" do
    @definition.current_time.should == Time.utc(2007, 6, 1)
  end
  
  it "should create table instances" do
    @definition.tables[:users].should be_kind_of(Table)
  end
  
  it "should retrieve default fixtures" do
    @definition.retrieve_record(:user).should       == @definition.tables[:users].default.record
  end
  
  it "should retrieve fixtures" do
    @definition.retrieve_record(:admin_user).should == @definition.tables[:users].fixtures[:admin].record
  end
end

describe Definition, "setup" do
  before :all do
    @definition = FixtureMocking.definitions[:default]
    @tester = FakeTester.new
  end
  
  it "should set definition value" do
    FakeTester.definition.should == @definition
  end
  
  it "should retrieve default fixtures" do
    @tester.fixtures(:user).should       == @definition.tables[:users].default.record
  end
  
  it "should retrieve fixtures" do
    @tester.fixtures(:admin_user).should == @definition.tables[:users].fixtures[:admin].record
  end
  
  it "should retrieve default fixtures with fixture table method" do
    @tester.users(:default).should       == @definition.tables[:users].default.record
  end
  
  it "should retrieve fixtures with fixture table method" do
    @tester.users(:admin).should == @definition.tables[:users].fixtures[:admin].record
  end
end

describe Table do
  before :all do
    @table = FixtureMocking.definitions[:default].tables[:users]
  end
  
  it "should be defined in fixture file" do
    @table.should be_kind_of(Table)
  end

  it "should retrieve fixtures" do
    @table.retrieve_record(:default).should == @table.default.record
    @table.retrieve_record(:admin).should   == @table.fixtures[:admin].record
  end
end

describe Table, "initialization with default options" do
  before :all do
    pending "Can't use default options without ActiveSupport" unless Object.const_defined?(:ActiveSupport)
    @default = Table.new(nil, :strings)
  end
  
  it "should set Table#name" do
    @default.name.should == :strings
  end
  
  it "should set class" do
    @default.model.should == String
  end
  
  it "should set plural value" do
    @default.plural.should == :strings
  end
  
  it "should set singular value" do
    @default.singular.should == 'string'
  end
end

describe Table, "initialization with custom options" do
  before :all do
    @custom  = Table.new(nil, :customs, :model => String, :plural => :many_customs, :singular => :one_custom)
  end
  
  it "should set Table#name" do
    @custom.name.should == :customs
  end
  
  it "should set class" do
    @custom.model.should == String
  end
  
  it "should set plural value" do
    @custom.plural.should == :many_customs
  end
  
  it "should set singular value" do
    @custom.singular.should == :one_custom
  end
end

describe Fixture do
  before :all do
    @definition = FixtureMocking.definitions[:default]
    @users      = @definition.tables[:users]
    @posts      = @definition.tables[:posts]
    @user       = @users.default
    @post       = @posts.default
  end

  it "should be defined in fixture file" do
    @user.should be_kind_of(Fixture)
  end
  
  it "should have the default fixture's attributes" do
    @user.attributes.should == {:name => 'bob', :admin => false}
  end
  
  it "should merge named fixture attributes with default attributes" do
    @users.fixtures[:admin].attributes.should == {:name => 'bob', :admin => true}
  end
  
  it "should set default table fixtures in the definition's global fixtures" do
    @definition.fixtures[:user].should == @user
  end
  
  it "should set custom table fixtures in the defintion's global fixture with fixture name prefix" do
    @definition.fixtures[:admin_user].should == @users.fixtures[:admin]
  end
end

describe Fixture, "instantiating a record" do
  before :all do
    @table   = FixtureMocking.definitions[:default].tables[:users]
    @fixture = @table.default
  end
  
  before do
    FixtureMocking.definitions[:default].tables[:posts].records.clear
    @table.records.clear
  end
  
  it "should set id" do
    @fixture.record.id.should >= 1000
  end
  
  it "should be of the table's model class" do
    @record  = @fixture.record
    @record.should be_kind_of(@table.model)
  end
  
  it "should set correct attributes" do
    @record  = @fixture.record
    @record.name.should  == 'bob'
    @record.admin.should == false
  end
  
  it "should allow custom attributes during instantiation" do
    @record  = @fixture.record :admin => true
    @record.admin.should == true
  end
  
  it "should allow use of #current_time in a fixture" do
    FixtureMocking.definitions[:default].tables[:posts].default.record.published_at.should == Time.utc(2007, 6, 6)
  end
end

describe Fixture, "instantiating a record with an association" do
  before :all do
    @definition = FixtureMocking.definitions[:default]
    @users      = @definition.tables[:users]
    @posts      = @definition.tables[:posts]
    @user       = @users.fixtures[:admin]
    @post       = @posts.default
  end
  
  before do
    @posts.records.clear
    @users.records.clear
  end
  
  it "should stub associated records" do
    @post.record.user.should == @user.record
  end
end

describe Fixture, "instantiating a record with an association and custom attributes" do
  before :all do
    @definition = FixtureMocking.definitions[:default]
    @users      = @definition.tables[:users]
    @posts      = @definition.tables[:posts]
    @user       = @users.fixtures[:admin]
    @post       = @posts.default
    @record     = @post.record(:title => 'foo bar', :user => { :name => 'fred' })
  end
  
  it "should set record's custom attributes" do
    @record.title.should     == 'foo bar'
    @record.title.should_not == @post.record.title
  end
  
  it "should set record's custom attributes" do
    @record.user.name.should     == 'fred'
    @record.user.should_not == @user.record
  end
end