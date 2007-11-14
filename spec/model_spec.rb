require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Model do
  before :all do
    @model = ModelStubbing.definitions[:default].models[:users]
  end
  
  it "is defined in stub file" do
    @model.should be_kind_of(Model)
  end

  it "retrieves stubs" do
    @model.retrieve_record(:default).should == @model.default.record
    @model.retrieve_record(:admin).should   == @model.stubs[:admin].record
  end
end

describe Model, "initialization with default options" do
  before :all do
    pending "Can't use default options without ActiveSupport" unless Object.const_defined?(:ActiveSupport)
    @default = Model.new(nil, Post)
  end
  
  it "sets Model#name" do
    @default.name.should == :posts
  end
  
  it "sets class" do
    @default.model_class.should == Post
  end
  
  it "sets plural value" do
    @default.plural.should == :posts
  end
  
  it "sets singular value" do
    @default.singular.should == 'post'
  end
end

describe Model, "initialization with custom options" do
  before :all do
    @custom  = Model.new(nil, Post, :name => :customs, :plural => :many_customs, :singular => :one_custom)
  end
  
  it "sets Model#name" do
    @custom.name.should == :customs
  end
  
  it "sets class" do
    @custom.model_class.should == Post
  end
  
  it "sets plural value" do
    @custom.plural.should == :many_customs
  end
  
  it "sets singular value" do
    @custom.singular.should == :one_custom
  end
end