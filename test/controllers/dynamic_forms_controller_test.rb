require 'test_helper'

class DynamicFormsControllerTest < ActionController::TestCase
  setup do
    @dynamic_form = dynamic_forms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dynamic_forms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dynamic_form" do
    assert_difference('DynamicForm.count') do
      post :create, dynamic_form: { description: @dynamic_form.description, expired: @dynamic_form.expired, name: @dynamic_form.name, properties: @dynamic_form.properties, recipient: @dynamic_form.recipient, title: @dynamic_form.title }
    end

    assert_redirected_to dynamic_form_path(assigns(:dynamic_form))
  end

  test "should show dynamic_form" do
    get :show, id: @dynamic_form
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dynamic_form
    assert_response :success
  end

  test "should update dynamic_form" do
    patch :update, id: @dynamic_form, dynamic_form: { description: @dynamic_form.description, expired: @dynamic_form.expired, name: @dynamic_form.name, properties: @dynamic_form.properties, recipient: @dynamic_form.recipient, title: @dynamic_form.title }
    assert_redirected_to dynamic_form_path(assigns(:dynamic_form))
  end

  test "should destroy dynamic_form" do
    assert_difference('DynamicForm.count', -1) do
      delete :destroy, id: @dynamic_form
    end

    assert_redirected_to dynamic_forms_path
  end
end
