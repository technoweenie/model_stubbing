require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Stub do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @users      = @definition.models[:users]
    @posts      = @definition.models[:posts]
    @user       = @users.default
    @post       = @posts.default
  end

  it "should be defined in stub file" do
    @user.should be_kind_of(Stub)
  end
  
  it "should have the default stub's attributes" do
    @user.attributes.should == {:name => 'bob', :admin => false}
  end
  
  it "should merge named stub attributes with default attributes" do
    @users.stubs[:admin].attributes.should == {:name => 'bob', :admin => true}
  end
  
  it "should set default model stubs in the definition's global stubs" do
    @definition.stubs[:user].should == @user
  end
  
  it "should set custom model stubs in the defintion's global stub with stub name prefix" do
    @definition.stubs[:admin_user].should == @users.stubs[:admin]
  end
end

describe Stub, "instantiating a record" do
  before :all do
    @model   = ModelStubbing.definitions[:default].models[:users]
    @stub = @model.default
  end
  
  before do
    ModelStubbing.definitions[:default].models[:posts].records.clear
    @model.records.clear
  end
  
  it "should set id" do
    @stub.record.id.should >= 1000
  end
  
  it "should be of the model's model class" do
    @record  = @stub.record
    @record.should be_kind_of(@model.model_class)
  end
  
  it "should set correct attributes" do
    @record  = @stub.record
    @record.name.should  == 'bob'
    @record.admin.should == false
  end
  
  it "should allow custom attributes during instantiation" do
    @record  = @stub.record :admin => true
    @record.admin.should == true
  end
  
  it "should allow use of #current_time in a stub" do
    ModelStubbing.definitions[:default].models[:posts].default.record.published_at.should == Time.utc(2007, 6, 6)
  end
end

describe Stub, "instantiating a record with an association" do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @users      = @definition.models[:users]
    @posts      = @definition.models[:posts]
    @user       = @users.stubs[:admin]
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

describe Stub, "instantiating a record with an association and custom attributes" do
  before :all do
    @definition = ModelStubbing.definitions[:default]
    @users      = @definition.models[:users]
    @posts      = @definition.models[:posts]
    @user       = @users.stubs[:admin]
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