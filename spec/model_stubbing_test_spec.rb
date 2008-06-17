require File.join(File.dirname(__FILE__), 'models')
require 'test/spec'
require 'mocha'

module ModelStubbing
  describe "Sample" do
    define_models
  
    def test_should_retrieve_stubs
      assert_equal 'bob', model_stubbing_users(:default).name
      assert_equal false, model_stubbing_users(:default).admin
    
      assert_equal 'bob', model_stubbing_users(:admin).name
      assert model_stubbing_users(:admin).admin
    end
  
    def test_should_retrieve_new_records_based_on_stubs
      record = new_model_stubbing_user(:default)
      assert_equal 'bob', record.name
      assert_equal false, record.admin
    end
  
    def test_should_retrieve_instantiated_stubs
      assert_equal model_stubbing_users(:default).id, model_stubbing_users(:default).id
    end
  
    def test_should_retrieve_instantiated_new_records_based_on_stubs
      record1 = new_model_stubbing_user(:default)
      assert_nil record1.id
      assert     record1.new_record?
      
      record2 = new_model_stubbing_user
      assert_nil record2.id
      assert     record2.new_record?
      
      assert_not_equal record1.object_id, record2.object_id
    end
  
    def test_should_save_instantiated_new_records_based_on_stubs
      record = new_model_stubbing_user!
      assert !record.id.nil?
      assert !record.new_record?
      assert_equal 'bob', record.name
    end
  
    def test_should_save_instantiated_new_records_based_on_stubs_with_custom_attributes
      record = new_model_stubbing_user!(:name => 'jane')
      assert !record.id.nil?
      assert !record.new_record?
      assert_equal 'jane', record.name
    end
  
    def test_should_generate_custom_stubs
      custom = model_stubbing_users(:default, :admin => true)
      assert_not_equal model_stubbing_users(:default).id, custom.id
      assert_equal custom.id, model_stubbing_users(:default, :admin => true).id
    end
  
    def test_should_associate_belongs_to_stubs
      assert_equal model_stubbing_users(:admin), model_stubbing_posts(:default).user
    end
  
    def test_should_associate_has_many_stubs
      assert_equal model_stubbing_posts(:nice_one).tags, [model_stubbing_tags(:foo), model_stubbing_tags(:bar)]
    end
  
    def test_should_stub_current_time
      assert_equal Time.utc(2007, 6, 1), current_time
      assert_equal Time.utc(2007, 6, 6), model_stubbing_posts(:default).published_at
    end
  end
end