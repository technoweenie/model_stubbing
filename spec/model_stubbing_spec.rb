require File.join(File.dirname(__FILE__), 'spec_helper')

module ModelStubbing
  describe "Sample Stub Usage" do

    define_models do
      time 2007, 6, 1
    
      model User do
        stub :name => 'fred', :admin => false
        stub :admin, :admin => true
      end
    
      model Post do
        stub :title => 'first', :user => all_stubs(:admin_model_stubbing_user), :published_at => current_time + 5.days
      end
    end
    
    it "retrieves stubs" do
      model_stubbing_users(:default).name.should == 'fred'
      model_stubbing_users(:default).admin.should == false
      
      model_stubbing_users(:admin).name.should == 'fred'
      model_stubbing_users(:admin).admin.should == true
    end
    
    it "retrieves new records based on stubs" do
      record = new_model_stubbing_user(:default)
      record.name.should == 'fred'
      record.admin.should == false
    end
    
    it "retrieves instantiated stubs" do
      model_stubbing_users(:default).id.should == model_stubbing_users(:default).id
      model_stubbing_users(:default).should_not be_new_record
    end
    
    it "retrieves instantiated new records based on stubs" do
      record = new_model_stubbing_user(:default)
      record.id.should be_nil
      record.should be_new_record
    end
  
    it "generates custom stubs" do
      default = model_stubbing_users(:default)
      custom  = model_stubbing_users(:default, :admin => true)
      custom.id.should_not == default.id
      custom.id.should == model_stubbing_users(:default, :admin => true).id
    end
    
    it "associates stubs" do
      model_stubbing_posts(:default).user.should == model_stubbing_users(:admin)
    end
    
    it "stubs current time" do
      current_time.should == Time.utc(2007, 6, 1)
      model_stubbing_posts(:default).published_at.should == Time.utc(2007, 6, 6)
    end
  end
end