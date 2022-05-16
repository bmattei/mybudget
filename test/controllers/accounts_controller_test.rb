require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:dcu_savings)
  end

  test "should get index" do
    get accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_account_url
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post accounts_url, params: { account: { bank: @account.bank, has_checking: @account.has_checking,
         name: "New_Checking", number: "99990000000"} }
    end

    assert_redirected_to accounts_url
  end

  test "should show account" do
    get account_url(@account)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_url(@account)
    assert_response :success
  end

  test "should update account" do
    new_name = "Foobarbabby"
    patch account_url(@account), params: { account: { bank: @account.bank, has_checking: @account.has_checking, name: new_name, number: @account.number } }
    @account.reload
    assert_equal @account.name, new_name, "NAME WAS NOT UPDATED"
    assert_redirected_to accounts_url()
  end

  test "should destroy account" do
    assert_difference("Account.count", -1) do
      delete account_url(@account)
    end

    assert_redirected_to accounts_url
  end
end
