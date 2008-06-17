require File.join(File.dirname(__FILE__), 'spec_helper')

module ModelStubbing
  describe "Sample Stub Usage" do
    define_models

    it "retrieves stubs" do
      model_stubbing_users(:default).name.should == 'bob'
      model_stubbing_users(:default).admin.should == false
      
      model_stubbing_users(:admin).name.should == 'bob'
      model_stubbing_users(:admin).admin.should == true
    end
    
    it "retrieves new records based on stubs" do
      record = new_model_stubbing_user(:default)
      record.name.should == 'bob'
      record.admin.should == false
    end
    
    it "retrieves instantiated stubs" do
      model_stubbing_users(:default).id.should == model_stubbing_users(:default).id
      model_stubbing_users(:default).should_not be_new_record
    end
    
    it "retrieves instantiated new records based on stubs" do
      record1 = new_model_stubbing_user(:default)
      record1.id.should be_nil
      record1.should be_new_record
  
      record2 = new_model_stubbing_user
      record2.id.should be_nil
      record2.should be_new_record
      
      record1.object_id.should_not == record2.object_id
    end
  
    it "saves instantiated new records based on stubs" do
      record = new_model_stubbing_user!
      record.id.should_not be_nil
      record.should_not be_new_record
      record.name.should == 'bob'
    end
  
    it "saves instantiated new records based on stubs with custom attributes" do
      record = new_model_stubbing_user!(:name => 'jane')
      record.id.should_not be_nil
      record.should_not be_new_record
      record.name.should == 'jane'
    end
  
    it "generates custom stubs" do
      default = model_stubbing_users(:default)
      custom  = model_stubbing_users(:default, :admin => true)
      custom.id.should_not == default.id
      custom.id.should == model_stubbing_users(:default, :admin => true).id
    end
    
    it "associates belongs_to stubs" do
      model_stubbing_posts(:default).user.should == model_stubbing_users(:admin)
    end
    
    it "associates has_many stubs" do
      model_stubbing_posts(:nice_one).tags.should == [model_stubbing_tags(:foo), model_stubbing_tags(:bar)]
    end
    
    it "stubs current time" do
      current_time.should == Time.utc(2007, 6, 1)
      model_stubbing_posts(:default).published_at.should == Time.utc(2007, 6, 6)
    end
  end
end