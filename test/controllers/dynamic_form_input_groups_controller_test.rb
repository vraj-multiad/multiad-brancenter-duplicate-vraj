require 'test_helper'

class DynamicFormInputGroupsControllerTest < ActionController::TestCase
  setup do
    @dynamic_form_input_group = dynamic_form_input_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dynamic_form_input_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dynamic_form_input_group" do
    assert_difference('DynamicFormInputGroup.count') do
      post :create, dynamic_form_input_group: { description: @dynamic_form_input_group.description, dynamic_form_id: @dynamic_form_input_group.dynamic_form_id, dynamic_form_id: @dynamic_form_input_group.dynamic_form_id, input_group_type: @dynamic_form_input_group.input_group_type, name: @dynamic_form_input_group.name, title: @dynamic_form_input_group.title }
    end

    assert_redirected_to dynamic_form_input_group_path(assigns(:dynamic_form_input_group))
  end

  test "should show dynamic_form_input_group" do
    get :show, id: @dynamic_form_input_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dynamic_form_input_group
    assert_response :success
  end

  test "should update dynamic_form_input_group" do
    patch :update, id: @dynamic_form_input_group, dynamic_form_input_group: { description: @dynamic_form_input_group.description, dynamic_form_id: @dynamic_form_input_group.dynamic_form_id, dynamic_form_id: @dynamic_form_input_group.dynamic_form_id, input_group_type: @dynamic_form_input_group.input_group_type, name: @dynamic_form_input_group.name, title: @dynamic_form_input_group.title }
    assert_redirected_to dynamic_form_input_group_path(assigns(:dynamic_form_input_group))
  end

  test "should destroy dynamic_form_input_group" do
    assert_difference('DynamicFormInputGroup.count', -1) do
      delete :destroy, id: @dynamic_form_input_group
    end

    assert_redirected_to dynamic_form_input_groups_path
  end
end
