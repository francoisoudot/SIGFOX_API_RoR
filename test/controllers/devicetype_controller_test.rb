require 'test_helper'

class DevicetypeControllerTest < ActionController::TestCase
  test "should get id:string" do
    get :id:string
    assert_response :success
  end

end
