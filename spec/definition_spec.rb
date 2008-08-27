require File.join(File.dirname(__FILE__), 'spec_helper')

module ModelStubbing
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
      @definition.models[:model_stubbing_users].should be_kind_of(Model)
    end
    
    it "retrieves default stubs" do
      @definition.retrieve_record(:model_stubbing_user).should == @definition.models[:model_stubbing_users].default.record
    end
    
    it "retrieves stubs" do
      @definition.retrieve_record(:admin_model_stubbing_user).should == @definition.models[:model_stubbing_users].stubs[:admin].record
    end
    
    it "keeps order of defined models" do
      @definition.ordered_models.should == [@definition.models[:model_stubbing_users], @definition.models[:model_stubbing_foo_bars], @definition.models[:model_stubbing_tags], @definition.models[:model_stubbing_posts]]
    end
  end
  
  describe Definition, "setup" do
    before :all do
      @definition = ModelStubbing.definitions[:default]
      @tester = FakeTester.new :test_booya
    end
    
    it "sets definition value" do
      FakeTester.definition.should == @definition
    end
    
    it "retrieves default stubs" do
      @tester.stubs(:model_stubbing_user).should == @definition.models[:model_stubbing_users].default
    end
    
    it "retrieves stubs" do
      @tester.stubs(:admin_model_stubbing_user).should == @definition.models[:model_stubbing_users].stubs[:admin]
    end
    
    it "retrieves default stubs with stub model method" do
      @tester.model_stubbing_users(:default).should == @definition.models[:model_stubbing_users].default.record
    end
    
    it "retrieves stubs with stub model method" do
      @tester.model_stubbing_users(:admin).should == @definition.models[:model_stubbing_users].stubs[:admin].record
    end
  end
  
  describe Definition, "duping itself" do
    before :all do
      @defn = ModelStubbing.definitions[:default]
      @copy = @defn.dup
    end
    
    it "dups @current_time" do
      @defn.current_time.should == @copy.current_time
    end
  
    it "transfers ordered_models" do
      @copy.ordered_models.collect(&:name).should == @defn.ordered_models.collect(&:name)
    end
    
    it "dups ordered_model instances" do
      @copy.ordered_models.each_with_index do |model, i|
        @copy.ordered_models[i].should == @defn.ordered_models[i]
        @copy.ordered_models[i].should_not be_equal(@defn.ordered_models[i])
      end
    end
  
    it "dups each model" do
      @defn.models.each do |name, model|
        duped_model = @copy.models[name]
        model.should == duped_model
        model.should_not be_equal(duped_model)
        model.stubs.each do |key, stub|
          duped_stub = @copy.models[name].stubs[key]
          stub.should == duped_stub
          stub.should_not be_equal(duped_stub)
        end
      end
    end
  
    it "dups each stub" do
      @defn.stubs.each do |name, stub|
        duped_stub = @copy.stubs[name]
        stub.should == duped_stub
        stub.should_not be_equal(duped_stub)
      end
    end
  
    it "is not the same instance" do
      @defn.object_id.should_not == @copy.object_id
    end
    
    it "is still be equal" do
      @defn.should == @copy
    end
  end
end