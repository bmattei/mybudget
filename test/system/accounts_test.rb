require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:dcu_checking)
  end

  test "visiting the index" do
    visit accounts_url
    assert_selector "h1", text: "Accounts"
    assert_text "Name"
    assert_text "Number"
    assert_text "Bank"
    assert_text "Has Checking"
    assert_text @account.name
    assert_text @account.number
    assert_text @account.bank

  end
  test "should create account" do
    visit accounts_url
    click_on "New account"

    name = "MyNewName"
    number = "A1222222"
    fill_in "Bank", with: @account.bank
    check "Has checking" if @account.has_checking
    fill_in "Name", with: name
    fill_in "Number", with: number
    click_on "Create Account"

    assert current_url, accounts_url
    assert_text "Account was successfully created"
    assert_text name
    assert_text number
  end

  test "should update Account" do
    visit account_url(@account)
    click_on "Edit this account", match: :first

    name = "MyNewName"
    number = "A1222222"
    fill_in "Bank", with: @account.bank
    check "Has checking" if @account.has_checking
    fill_in "Name", with: name
    fill_in "Number", with: number
    click_on "Update Account"

    assert current_url, accounts_url
    assert_text "Account was successfully updated"
    assert_text name
    assert_text number
  end

  test "should destroy Account" do
    visit account_url(@account)
    click_on "Destroy this account", match: :first

    assert_text "Account was successfully destroyed"
  end
end
