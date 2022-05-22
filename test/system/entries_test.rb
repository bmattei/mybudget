require "application_system_test_case"

class EntriesTest < ApplicationSystemTestCase
  INFLOW_IDX = 5
  OUTFLOW_IDX = 6
  setup do
    @entry = entries(:discover_init)
    @account = accounts(:discover)
  end

  test "visiting the index" do
    visit entries_url
    assert_selector "h1", text: "Entries"
  end

  test "should create entry" do
    visit account_url(@account)
    click_on "New", match: :first

    payee = "ODD NAME Restaurant"
    fill_in "Outflow", with: 83.11
    select categories(:restaurants).name, from: "entry[category_id]"
    fill_in "Entry date", with: Date.today
    fill_in "Payee", with: payee
    click_on "Create Entry"

    assert_text "Entry was successfully created"
    assert_equal current_url, account_url(@account)
    assert_text payee
  end

  test "should update Entry" do
    visit account_url(@entry.account)
    click_on "Edit", match: :first
    fill_in "Outflow", with: @entry.amount.abs
    select categories(:transportation).name, from: "entry[category_id]"
    fill_in "Check number", with: @entry.check_number
    fill_in "Entry date", with: @entry.entry_date
    fill_in "Payee", with: @entry.payee
    click_on "Update Entry"

    assert_text "Entry was successfully updated"
    assert_equal account_url(@entry.account), current_url
  end

  test "Should create transfer entries" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)
    click_on "New", match: :first
    fill_in "Entry date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "Outflow", with: amount
    click_on "Create Entry"
    assert_text "Entry was successfully created", wait: 5
  end
  test "Should create transfer out entry with correct outflow" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "Entry date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "Outflow", with: amount
    click_on "Create Entry"

    assert_text "Entry was successfully created", wait: 5
    last_entry = all(".table-row-group>.table-row").last
    outflow = last_entry.all(".table-cell")[OUTFLOW_IDX].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), outflow

  end
  test "Should create transfer out entry with correct inflow in other account" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "Entry date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "Outflow", with: amount
    click_on "Create Entry"

    assert_text "Entry was successfully created", wait: 5

    visit account_url(other_account)
    last_entry = all(".table-row-group>.table-row").last
    inflow = last_entry.all(".table-cell")[INFLOW_IDX].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), inflow
  end

  test "Should create transfer in entry with correct inflow" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "Entry date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "Outflow", with: amount

    click_on "Create Entry"
    assert_text "Entry was successfully created", wait: 5

    visit account_url(other_account)

    last_entry = all(".table-row-group>.table-row").last
    inflow = last_entry.all(".table-cell")[INFLOW_IDX].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), inflow
  end
  test "Should create transfer in entry with correct outflow in other account" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 412.22
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "Entry date", with: Date.today + 1
    fill_in "Inflow", with: amount
    select  other_account.name, from: "entry_transfer_account_id"
    click_on "Create Entry"

    assert_text "Entry was successfully created", wait: 5
    visit account_url(other_account)
    last_entry = all(".table-row-group>.table-row").last
    outflow = last_entry.all(".table-cell")[OUTFLOW_IDX].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), outflow
  end
  test "should destroy Entry" do
    skip "for now"

  end
end
