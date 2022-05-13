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
    assert_text "Checking"
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

  test "should get an error if you attempt to create account without bank" do
    visit accounts_url
    name = "NoBankAccount"
    number = "NoBank_123"
    click_on "New account"
    fill_in "Name", with: name
    fill_in "Number", with:number
    click_on "Create Account"
    assert_text "Bank can't be blank"

  end

  test "Should be able to edit and account" do
    visit accounts_url
    name = "MY NEW NAME"
    click_on "edit", match: :first
    old_name = find_field('Name').value
    fill_in "Name", with: name
    click_on "Update Account"
    assert current_url, accounts_url
    assert_text name
    assert_text old_name, count:0
  end

  test "Should be able to cancel a create" do
    visit accounts_url
    name = "CancelAccount"
    number = "CancelNumber123"
    bank = "CancelBank"
    click_on "New account"
    fill_in "Name", with: name
    fill_in "Number", with:number
    fill_in "Bank", with:bank
    click_on "Cancel"
    assert current_url, accounts_url
    assert_text name, count:0
    assert_text number, count:0
    assert_text bank, count:0
  end


  test "should be able to filter by name" do
    visit accounts_url

    # This account should be in table to start test

    assert_text @account.number

    filter_account = accounts(:filter_me)
    fill_in "Name Contains", with: filter_account.name
    click_on "Filter"
    # this account should now be filtered out
    assert_text @account.number, count: 0
    # This account should still be there
    assert_text filter_account.number
  end
  test "should be able to filter by bank" do
    visit accounts_url
    # This account should be in table to start test
    assert_text @account.number

    filter_account = accounts(:filter_me)
    fill_in "Bank Contains", with: filter_account.bank
    click_on "Filter"
    # this account should now be filtered out
    assert_text @account.number, count: 0
    assert_text filter_account.number
  end
  test "should be able to filter by number" do
    visit accounts_url
    # This account should be in table to start test
    assert_text @account.number
    filter_account = accounts(:filter_me)
    fill_in "Number Contains", with: filter_account.number
    click_on "Filter"
    # this account should now be filtered out
    assert_text @account.number, count: 0
    assert_text filter_account.number
  end
  test "should be able to sort by Bank" do
    visit accounts_url
    click_on "Bank"
    rows_count = all(".table-row-group>.table-row").count
    last_bank = all( ".table-row-group>.table-row:nth-child(1)>.table-cell").first.text
    (2..rows_count).each do |i|
         bank =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell").first.text
         assert bank >= last_bank, "#{bank} >= #{last_bank}"
    end
    click_on "Bank"
    # I think I need this because of turbo
    sleep(3)

    last_bank = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(1)").first.text
    (2..rows_count).each do |i|
        bank =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell").first.text
        assert bank <= last_bank, "#{bank} <= #{last_bank}"
    end

  end
  test "should be able to sort by Name" do
    visit accounts_url
    click_on "Name"
    rows_count = all(".table-row-group>.table-row").count
    last_name = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(2)").first.text
    (2..rows_count).each do |i|
         name =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(2)").first.text
         assert name>= last_name, "#{name} >= #{last_name}"
    end
    click_on "Name"
    # I think I need this because of turbo
    sleep(3)

    last_name = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(2)").first.text
    (2..rows_count).each do |i|
        name =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(2)").first.text
        assert name <= last_name, "#{name} <= #{last_name}"
    end

  end
  test "should be able to sort by Number" do
    visit accounts_url
    click_on "Number"
    rows_count = all(".table-row-group>.table-row").count
    last_number = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(3)").first.text
    (2..rows_count).each do |i|
         number =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(3)").first.text
         assert number>= last_number, "#{number} >= #{last_number}"
    end
    click_on "Number"
    # I think I need this because of turbo
    sleep(3)

    last_number = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(3)").first.text
    (2..rows_count).each do |i|
        number =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(3)").first.text
        assert number <= last_number, "#{number} <= #{last_number}"
    end

  end

  test "should be able to sort by checking" do
    visit accounts_url
    click_on "Checking"
    rows_count = all(".table-row-group>.table-row").count
    last_value = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(4)").first.text
    (2..rows_count).each do |i|
         value =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(4)").first.text
         assert value >= last_value, "#{value} >= #{last_value}"
    end
    click_on "Checking"
    # I think I need this because of turbo
    sleep(3)

    last_value = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(4)").first.text
    (2..rows_count).each do |i|
        value =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(4)").first.text
        assert value <= last_value, "#{value} <= #{last_value}"
    end

  end



  test "should destroy Account from Accounts index" do
    skip 'Capabara seems to have problems when method is set in turbo data'

    visit accounts_url
    # We should have a row for each account
    count = Account.count
    assert_text "delete", count: count
    accept_alert do
       click_on "delete", match: :first
    end
    # we should have one less row
    assert_text "delete", count: count-1
    assert_text "Account was successfully destroyed"
  end
end
