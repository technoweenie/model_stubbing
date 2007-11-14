require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Definition do
  before :all do
    @definition = ModelStubbing.definitions[:default]
  end
  
  it "defines as default definition" do
    @definition.should be_kind_of(Definition)
  end
  
  it "sets #current_time" do
    @definition.current_time.should == Time.utc(2007, 6, 1)
  end
  
  it "creates model instances" do
    @definition.models[:users].should be_kind_of(Model)
  end
  
  it "retrieves default stubs" do
    @definition.retrieve_record(:user).should       == @definition.models[:users].default.record
  end
  
  it "retrieves stubs" do
    @definition.retrieve_record(:admin_user).should == @definition.models[:users].stubs[:admin].record
  end
end

describe Definition, "setup" do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @tester = FakeTester.new
  end
  
  it "sets definition value" do
    FakeTester.definition.should == @definition
  end
  
  it "retrieves default stubs" do
    @tester.stubs(:user).should       == @definition.models[:users].default.record
  end
  
  it "retrieves stubs" do
    @tester.stubs(:admin_user).should == @definition.models[:users].stubs[:admin].record
  end
  
  it "retrieves default stubs with stub model method" do
    @tester.users(:default).should       == @definition.models[:users].default.record
  end
  
  it "retrieves stubs with stub model method" do
    @tester.users(:admin).should == @definition.models[:users].stubs[:admin].record
  end
end