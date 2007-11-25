require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Sample Stub Usage" do
  define_models do
    time 2007, 6, 1
  
    model User do
      stub :name => 'fred', :admin => false
      stub :admin, :admin => true
    end
  
    model Post do
      stub :title => 'first', :user => all_stubs(:admin_user), :published_at => current_time + 5.days
    end
  end
  
  it "retrieves stubs" do
    users(:default).name.should == 'fred'
    users(:default).admin.should == false
    
    users(:admin).name.should == 'fred'
    users(:admin).admin.should == true
  end
  
  it "retrieves new records based on stubs" do
    record = new_user(:default)
    record.name.should == 'fred'
    record.admin.should == false
  end
  
  it "retrieves instantiated stubs" do
    users(:default).id.should == users(:default).id
    users(:default).should_not be_new_record
  end
  
  it "retrieves instantiated new records based on stubs" do
    record = new_user(:default)
    record.id.should be_nil
    record.should be_new_record
  end

  it "generates custom stubs" do
    default = users(:default)
    custom  = users(:default, :admin => true)
    custom.id.should_not == default.id
    custom.id.should == users(:default, :admin => true).id
  end
  
  it "associates stubs" do
    posts(:default).user.should == users(:admin)
  end
  
  it "stubbs current time" do
    current_time.should == Time.utc(2007, 6, 1)
    posts(:default).published_at.should == Time.utc(2007, 6, 6)
  end
end