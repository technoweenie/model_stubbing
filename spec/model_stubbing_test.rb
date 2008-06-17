require File.join(File.dirname(__FILE__), 'models')
require 'test/unit'
require 'mocha'

module ModelStubbing
  class SampleTest < Test::Unit::TestCase
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
  
    def test_should_retrieve_stubs
      assert_equal 'fred', model_stubbing_users(:default).name
      assert_equal false,  model_stubbing_users(:default).admin
    
      assert_equal 'fred', model_stubbing_users(:admin).name
      assert model_stubbing_users(:admin).admin
    end
  
    def test_should_retrieve_new_records_based_on_stubs
      record = new_model_stubbing_user(:default)
      assert_equal 'fred', record.name
      assert_equal false,  record.admin
    end
  
    def test_should_retrieve_instantiated_stubs
      assert_equal model_stubbing_users(:default).id, model_stubbing_users(:default).id
    end
  
    def test_should_retrieve_instantiated_new_records_based_on_stubs
      record = new_model_stubbing_user(:default)
      assert_nil record.id
      assert     record.new_record?
    end
  
    def test_should_generate_custom_stubs
      custom = model_stubbing_users(:default, :admin => true)
      assert_not_equal model_stubbing_users(:default).id, custom.id
      assert_equal custom.id, model_stubbing_users(:default, :admin => true).id
    end
  
    def test_should_associate_stubs
      assert_equal model_stubbing_users(:admin), model_stubbing_posts(:default).user
    end
  
    def test_should_stub_current_time
      assert_equal Time.utc(2007, 6, 1), current_time
      assert_equal Time.utc(2007, 6, 6), model_stubbing_posts(:default).published_at
    end
  end
end  