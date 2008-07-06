require File.join(File.dirname(__FILE__), 'spec_helper')

module ModelStubbing
  describe Stub do

    before :all do
      @definition = ModelStubbing.definitions[:default]
      @users      = @definition.models[:model_stubbing_users]
      @posts      = @definition.models[:model_stubbing_posts]
      @user       = @users.default
      @post       = @posts.default
    end

    it "is defined in stub file" do
      @user.should be_kind_of(Stub)
    end
  
    it "has the default stub's attributes" do
      @user.attributes.should == {:name => 'bob', :admin => false}
      @post.attributes.should == {:title => 'initial', :user => @users.stubs[:admin], :published_at => @definition.current_time + 5.days}
    end
  
    it "#with returns merged attributes" do
      @post.with(:title => 'fred').should == {:title => 'fred', :user => @users.stubs[:admin].record, :published_at => @definition.current_time + 5.days}
    end
  
    it "#only returns only given keys" do
      @post.only(:title).should == {:title => 'initial'}
    end
  
    it "#except returns other keys" do
      @post.except(:published_at).should == {:title => 'initial', :user => @users.stubs[:admin].record}
    end
  
    it "merges named stub attributes with default attributes" do
      @users.stubs[:admin].attributes.should == {:name => 'bob', :admin => true}
    end
  
    it "sets default model stubs in the definition's global stubs" do
      @definition.stubs[:model_stubbing_user].should == @user
    end
  
    it "sets custom model stubs in the defintion's global stub with stub name prefix" do
      @definition.stubs[:admin_model_stubbing_user].should == @users.stubs[:admin]
    end
  end

  describe Stub, "duping itself" do
    before :all do
      @stub = ModelStubbing.definitions[:default].models[:model_stubbing_users].default
      @copy = @stub.dup
    end 
  
    %w(name model attributes global_key).each do |attr|
      it "keeps @#{attr} intact" do
        @stub.send(attr).should == @copy.send(attr)
      end
    end
  
    it "is not the same instance" do
      @stub.object_id.should_not == @copy.object_id
    end
  
    it "is still be equal" do
      @stub.should == @copy
    end
  end

  describe Stub, "duping itself with duped model" do
    before :all do
      @stub = ModelStubbing.definitions[:default].models[:model_stubbing_users].default
      @copy = @stub.dup @stub.model.dup
    end 
  
    %w(name model attributes global_key).each do |attr|
      it "keeps @#{attr} intact" do
        @stub.send(attr).should == @copy.send(attr)
      end
    end
  
    it "is not the same instance" do
      @stub.object_id.should_not == @copy.object_id
    end
  
    it "is still be equal" do
      @stub.should == @copy
    end
  end

  describe Stub, "duping itself with different model" do
    before :all do
      @defn = ModelStubbing.definitions[:default]
      @stub = @defn.models[:model_stubbing_users].default
      @copy = @stub.dup @defn.models[:model_stubbing_posts].dup
    end
  
    %w(name attributes).each do |attr|
      it "keeps @#{attr} intact" do
        @stub.send(attr).should == @copy.send(attr)
      end
    end
  
    it "creates global key from new model" do
      @copy.global_key.should == :model_stubbing_post
    end
  
    it "is not the same instance" do
      @stub.object_id.should_not == @copy.object_id
    end
  
    it "is not equal" do
      @stub.should_not == @copy
    end
  end

  describe Stub, "instantiating a record" do
    before :all do
      @model   = ModelStubbing.definitions[:default].models[:model_stubbing_users]
      @stub = @model.default
    end
  
    before do
      ModelStubbing.records.clear
      ModelStubbing.record_ids.clear
    end
  
    it "sets id" do
      @stub.record.id.should >= 1000
    end
  
    it "is one of the model's model class" do
      @record  = @stub.record
      @record.should be_kind_of(@model.model_class)
    end
  
    it "is a saved record" do
      @stub.record.should_not be_new_record
    end
  
    it "sets correct attributes" do
      @record  = @stub.record
      @record.name.should  == 'bob'
      @record.admin.should == false
    end
  
    it "allows custom attributes during instantiation" do
      @record  = @stub.record :admin => true
      @record.admin.should == true
    end
  
    it "allows use of #current_time in a stub" do
      ModelStubbing.definitions[:default].models[:model_stubbing_posts].default.record.published_at.should == Time.utc(2007, 6, 6)
    end
  end

  describe Stub, "inserting a new record" do
    before :all do
      @defn  = ModelStubbing.definitions[:default]
      @model = @defn.models[:model_stubbing_users]
      @stub  = @model.default
      @opts  = @model.options.dup
    end
  
    before do
      ModelStubbing.records.clear
      ModelStubbing.record_ids.clear
      @model.options.update(@opts)
      @conn   = mock("Connection")
      @record = @stub.record
      @stub.stub!(:record).and_return(@record)
      @stub.stub!(:connection).and_return(@conn)
      @inserting_record = lambda { @stub.insert }
    end

    it "inserts an invalid record without validating" do
      @model.options.update(:validate => false, :callbacks => false)
      @record.valid = false
      @conn.should_receive(:insert_fixture)
      @inserting_record.call
    end

    it "raises error an invalid record with validation" do
      @model.options.update(:validate => true, :callbacks => false)
      @record.valid = false
      @conn.should_not_receive(:insert_fixture)
      @inserting_record.should raise_error
    end

    it "inserts valid record with validation" do
      @model.options.update(:validate => true, :callbacks => false)
      @record.valid = true
      @conn.should_receive(:insert_fixture)
      @inserting_record.call
    end

    it "raises error an invalid record with validation and callbacks" do
      @model.options.update(:validate => true, :callbacks => true)
      @record.valid = false
      @conn.should_not_receive(:insert_fixture)
      @inserting_record.should raise_error
    end

    it "inserts valid record with validation and callbacks" do
      @model.options.update(:validate => true, :callbacks => true)
      @record.valid = true
      @conn.should_not_receive(:insert_fixture)
      @inserting_record.call
    end
  end

  describe Stub, "instantiating a new record" do
    before :all do
      @model = ModelStubbing.definitions[:default].models[:model_stubbing_users]
      @stub  = @model.default
    end
  
    before do
      ModelStubbing.records.clear
      ModelStubbing.record_ids.clear
    end
  
    it "sets id" do
      @stub.record(:id => :new).id.should be_nil
    end
  
    it "is one of the model's model class" do
      @record  = @stub.record(:id => :new)
      @record.should be_kind_of(@model.model_class)
    end
  
    it "is a new record" do
      @stub.record(:id => :new).should be_new_record
    end
  
    it "is a unique new record" do
      @stub.record(:id => :new).object_id.should_not == @stub.record(:id => :new).object_id
    end
  
    it "sets correct attributes" do
      @record  = @stub.record(:id => :new)
      @record.name.should  == 'bob'
      @record.admin.should == false
    end
  
    it "allows custom attributes during instantiation" do
      @record  = @stub.record :admin => true, :id => :new
      @record.admin.should == true
    end
  
    it "allows use of #current_time in a stub" do
      ModelStubbing.definitions[:default].models[:model_stubbing_posts].default.record(:id => :new).published_at.should == Time.utc(2007, 6, 6)
    end
  end

  describe Stub, "instantiating a record with an association" do
    before :all do
      @definition = ModelStubbing.definitions[:default]
      @users      = @definition.models[:model_stubbing_users]
      @posts      = @definition.models[:model_stubbing_posts]
      @tags       = @definition.models[:model_stubbing_tags]
      @user       = @users.stubs[:admin]
      @post       = @posts.default
      @nice_one   = @posts.stubs[:nice_one]
      @tag_foo    = @tags.stubs[:foo]
      @tag_bar    = @tags.stubs[:bar]
    end
  
    before do
      ModelStubbing.records.clear
      ModelStubbing.record_ids.clear
    end
  
    it "stubs associated records" do
      @post.record.user.should == @user.record
    end
    
    it "stubs has_many associated records" do
      @nice_one.record.tags.should == [@tag_foo.record, @tag_bar.record]
    end
  end
end