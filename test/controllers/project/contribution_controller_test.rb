require "test_helper"

class Project::ContributionControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get project_contribution_new_url
    assert_response :success
  end

  test "should get create" do
    get project_contribution_create_url
    assert_response :success
  end

  test "should get edit" do
    get project_contribution_edit_url
    assert_response :success
  end

  test "should get update" do
    get project_contribution_update_url
    assert_response :success
  end

  test "should get show" do
    get project_contribution_show_url
    assert_response :success
  end
end
