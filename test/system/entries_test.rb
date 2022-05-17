require "application_system_test_case"

class EntriesTest < ApplicationSystemTestCase
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
    fill_in "Outflow", with: @entry.amount
    select categories(:transportation).name, from: "entry[category_id]"
    fill_in "Check number", with: @entry.check_number
    fill_in "Entry date", with: @entry.entry_date
    fill_in "Payee", with: @entry.payee
    click_on "Update Entry"

    assert_text "Entry was successfully updated"
    assert_equal account_url(@entry.account), current_url
  end

  test "should destroy Entry" do
    skip "for nwo"

  end
end
