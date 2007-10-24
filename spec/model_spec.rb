require File.join(File.dirname(__FILE__), 'spec_helper')
include ModelStubbing

describe Model do
  before :all do
    @model = ModelStubbing.definitions[:default].models[:users]
  end
  
  it "should be defined in stub file" do
    @model.should be_kind_of(Model)
  end

  it "should retrieve stubs" do
    @model.retrieve_record(:default).should == @model.default.record
    @model.retrieve_record(:admin).should   == @model.stubs[:admin].record
  end
end

describe Model, "initialization with default options" do
  before :all do
    pending "Can't use default options without ActiveSupport" unless Object.const_defined?(:ActiveSupport)
    @default = Model.new(nil, :strings)
  end
  
  it "should set Model#name" do
    @default.name.should == :strings
  end
  
  it "should set class" do
    @default.model_class.should == String
  end
  
  it "should set plural value" do
    @default.plural.should == :strings
  end
  
  it "should set singular value" do
    @default.singular.should == 'string'
  end
end

describe Model, "initialization with custom options" do
  before :all do
    @custom  = Model.new(nil, :customs, :class => String, :plural => :many_customs, :singular => :one_custom)
  end
  
  it "should set Model#name" do
    @custom.name.should == :customs
  end
  
  it "should set class" do
    @custom.model_class.should == String
  end
  
  it "should set plural value" do
    @custom.plural.should == :many_customs
  end
  
  it "should set singular value" do
    @custom.singular.should == :one_custom
  end
end