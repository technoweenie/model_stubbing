require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Definition do
  before :all do
    @definition = ModelStubbing.definitions[:default]
  end
  
  it "should be defined as default definition" do
    @definition.should be_kind_of(Definition)
  end
  
  it "should set #current_time" do
    @definition.current_time.should == Time.utc(2007, 6, 1)
  end
  
  it "should create model instances" do
    @definition.models[:users].should be_kind_of(Model)
  end
  
  it "should retrieve default stubs" do
    @definition.retrieve_record(:user).should       == @definition.models[:users].default.record
  end
  
  it "should retrieve stubs" do
    @definition.retrieve_record(:admin_user).should == @definition.models[:users].stubs[:admin].record
  end
end

describe Definition, "setup" do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @tester = FakeTester.new
  end
  
  it "should set definition value" do
    FakeTester.definition.should == @definition
  end
  
  it "should retrieve default stubs" do
    @tester.stubs(:user).should       == @definition.models[:users].default.record
  end
  
  it "should retrieve stubs" do
    @tester.stubs(:admin_user).should == @definition.models[:users].stubs[:admin].record
  end
  
  it "should retrieve default stubs with stub model method" do
    @tester.users(:default).should       == @definition.models[:users].default.record
  end
  
  it "should retrieve stubs with stub model method" do
    @tester.users(:admin).should == @definition.models[:users].stubs[:admin].record
  end
end