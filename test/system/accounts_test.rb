require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  include ApplicationHelper
  CATEGORY_COL = 1
  DATE_COL = 2
  CHECK_COL = 3
  PAYEE_COL = 4
  MEMO_COL = 5
  INFLOW_COL = 6
  OUTFLOW_COL = 7
  BALANCE_COL = 8                                                     
  CATEGORY_ID = "category_id"


  setup do
    @account = accounts(:dcu_checking)
    @discover = accounts(:discover)
    @entry = entries(:discover_init)
  end

  test "should create account" do
    visit accounts_url
    click_on "New"
    bank = "Wonder Band"
    name = "MyNewName"
    number = "A1222222"
    fill_in "account_bank", with: bank
    check "account_has_checking"
    fill_in "account_name", with: name
    fill_in "account_number", with: number
    click_on "Save"
    assert current_url, accounts_url
    assert_text "Account was successfully created"
    assert_text name
    assert_text number

  end

  test "New on account show page should put up form for new entry at top of table" do
    visit account_url(@account)
    click_on "New"
    assert_text "Cancel"
    assert_selector ".table-row-group .table-row:first-child .table-cell input#entry_entry_date"
    assert_selector ".table-row-group .table-row:first-child .table-cell select#entry_category_id"
    assert_selector ".table-row-group .table-row:first-child .table-cell input#entry_check_number"
    assert_selector ".table-row-group .table-row:first-child .table-cell select#entry_transfer_account_id"
    assert_selector ".table-row-group .table-row:first-child .table-cell input#entry_memo"
    assert_selector ".table-row-group .table-row:first-child .table-cell input#entry_inflow"
    assert_selector ".table-row-group .table-row:first-child .table-cell input#entry_outflow"
    assert_text @account.name
  end
  test "should create entry" do
    visit account_url(@account)
    click_on "New", match: :first
    payee = "ODD NAME Restaurant"
    fill_in "Outflow", with: 83.11
    select categories(:restaurants).name, from: "entry[category_id]"
    fill_in "entry_entry_date", with: Date.today
    fill_in "entry_payee", with: payee
    click_on "Save"
    assert_text "Entry was successfully created"
    assert_equal current_url, account_url(@account)
  end
  test "New entry should be in the first row of the table " do
    visit account_url(@account)
    click_on "New", match: :first
    payee = "ODD NAME Restaurant"
    fill_in "Outflow", with: 83.11
    select categories(:restaurants).name, from: "entry[category_id]"
    fill_in "entry_entry_date", with: Date.today
    fill_in "entry_payee", with: payee
    click_on "Save"
    assert_text "Entry was successfully created"
    assert_equal current_url, account_url(@account)
    # assert_selector ".table-row-group .table-row:first-child .table-cell"
    # I think this is complicated by the new_entry turbo-fram
    rows = find_all(".table-row-group .table-row")
    rows.first.assert_selector ".table-cell", text: payee

  end
  test "Should get error if you attempt to create entry with no inflow or outflow" do
    visit account_url(@account)
    click_on "New", match: :first
    payee = "ODD NAME Restaurant"
    select categories(:restaurants).name, from: "entry[category_id]"
    fill_in "entry_entry_date", with: Date.today
    fill_in "entry_payee", with: payee
    click_on "Save"
    assert_text "Amount can't be blank"
  end

  test "Issue #12 insure entry form after error appears on page correctly" do
    visit account_url(@account)
    click_on "New", match: :first
    payee = "ODD NAME Restaurant"
    select categories(:restaurants).name, from: "entry[category_id]"
    fill_in "entry_entry_date", with: Date.today
    fill_in "entry_payee", with: payee
    click_on "Save"
    assert_text "Amount can't be blank"

    # verify page is not missing elements
    assert_text @account.name
    assert_text "Outflow"
    assert_text "Memo"
    assert find("#toggle_filter")

  end
  # Theses tests were moved from entry test to here
  test "should be able to edit the payee field" do

    visit account_url(accounts(:dcu_checking))
    assert_text "DcuChecking"

    row = find_all(".table-row")[1]
    payee_cell = row.find_all(".table-cell")[PAYEE_COL]
    payee_cell.click
    NEW_PAYEE = "MY NEW PAYEE-jibber"
    payee_cell.set(NEW_PAYEE)
    payee_cell.send_keys :tab
    visit current_url
    row = find_all(".table-row")[1]
    payee_cell = row.find_all(".table-cell")[PAYEE_COL]
    assert_equal NEW_PAYEE, payee_cell.text

  end


  #  Added this test because creating entries was working on the first account
  #  in fixtures - only and I was not catching it.  This test verifies it works on other accounts
  test "should create discover entry" do
    initial_num_entries = @discover.entries.count
    visit account_url(@discover)
    click_on "New", match: :first

    payee = "ODD NAME Discover Restaurant"
    assert_text "Outflow"
    fill_in "Outflow", with: 129.90
    select categories(:restaurants).name, from: "entry[category_id]"
    fill_in "entry_entry_date", with: Date.today
    fill_in "entry_payee", with: payee
    click_on "Save"
    assert_text "Entry was successfully created"
    assert_equal current_url, account_url(@discover)
    assert_text payee
    assert_equal initial_num_entries + 1, @discover.entries.count
  end
  test "New Should remember the last date entered " do
    visit account_url(@account)
    click_on "New", match: :first

    payee = "ODD NAME Restaurant"
    fill_in "Outflow", with: 99.97
    select categories(:restaurants).name, from: "entry[category_id]"
    date = Date.today - 100
    fill_in "entry_entry_date", with: date
    fill_in "entry_payee", with: payee
    click_on "Save"
    assert_text "Entry was successfully created"

    click_on "New"
    form_date = find("#entry_entry_date").value
    assert_equal date.to_s, form_date
    end


  test "Should create transfer entries" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)
    click_on "New", match: :first
    fill_in "entry_entry_date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "entry_outflow", with: amount
    click_on "Save"
    assert_text "Entry was successfully created", wait: 5
  end
  test "Should create transfer out entry with correct outflow" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 409.99
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "entry_entry_date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "entry_outflow", with: amount
    click_on "Save"
    assert_text "Entry was successfully created", wait: 5
    first_entry = all(".table-row-group>.table-row").first
    outflow = first_entry.all(".table-cell")[OUTFLOW_COL].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), outflow

  end
  test "Should create transfer out entry with correct inflow in other account" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "entry_entry_date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "entry_outflow", with: amount
    click_on "Save"

    assert_text "Entry was successfully created", wait: 5

    visit account_url(other_account)
    first_entry = all(".table-row-group>.table-row").first
    inflow = first_entry.all(".table-cell")[INFLOW_COL].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), inflow
  end

  test "Should create transfer in entry with correct inflow" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 400
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "entry_entry_date", with: Date.today + 1
    select  other_account.name, from: "entry_transfer_account_id"
    fill_in "entry_outflow", with: amount

    click_on "Save"
    assert_text "Entry was successfully created", wait: 5

    visit account_url(other_account)

    first_entry = all(".table-row-group>.table-row").first
    inflow = first_entry.all(".table-cell")[INFLOW_COL].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), inflow
  end
  test "Should create transfer in entry with correct outflow in other account" do
    other_account = accounts(:discover)
    init_account = accounts(:dcu_checking)
    amount = 412.22
    visit account_url(init_account)

    click_on "New", match: :first
    fill_in "entry_entry_date", with: Date.today + 1
    fill_in "entry_inflow", with: amount
    select  other_account.name, from: "entry_transfer_account_id"
    click_on "Save"

    assert_text "Entry was successfully created", wait: 5
    visit account_url(other_account)
    first_entry = all(".table-row-group>.table-row").first
    outflow = first_entry.all(".table-cell")[OUTFLOW_COL].text
    assert_equal ActionController::Base.helpers.number_to_currency(amount), outflow
  end
  test "should destroy Entry" do
    skip "for now"

  end

  # End of moved tests

  test "visiting the index" do
    visit accounts_url
    
    assert_selector "div", text: "Accounts"
    assert_text "Name"
    assert_text "Number"
    assert_text "Bank"
    assert_text "Checking"
    assert_text @account.name
    assert_text @account.number
    assert_text @account.bank

  end


  test "should get an error if you attempt to create account without bank" do
    visit accounts_url
    name = "NoBankAccount"
    number = "NoBank_123"
    click_on "New"
    fill_in "account_name", with: name
    fill_in "account_number", with: number
    click_on "Save"
    sleep 3
    assert_text "Bank can't be blank"

  end

  test "Should be able to edit an account" do

    visit accounts_url
    assert_text "Accounts"
    row = find_all(".table-row")[1]
    name_cell = row.find('.table-cell[data-field="name"]')
    old_name = name_cell.text
    new_name =    old_name + "New Change"
    name_cell.click
    name_cell.set(new_name)
    name_cell.send_keys(:tab)
    refresh
    row = find_all(".table-row")[1]
    name_cell = row.find('.table-cell[data-field="name"]')
    assert_equal new_name, name_cell.text
  end

  test "Should be able to cancel a create" do
    visit accounts_url
    name = "CancelAccount"
    number = "CancelNumber123"
    bank = "CancelBank"
    click_on "New"
    fill_in "account_name", with: name
    fill_in "account_number", with:number
    fill_in "account_bank", with:bank
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
    find("#toggle_filter").click
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
    find("#toggle_filter").click
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
    find("#toggle_filter").click

    fill_in "Number Contains", with: filter_account.number
    click_on "Filter"
    # this account should now be filtered out
    assert_text @account.number, count: 0
    assert_text filter_account.number
  end
  test "should be able to sort by Bank" do
    visit accounts_url
    click_on "Bank"
    sleep 1
    rows = all(".table-row-group .table-row")
    last_bank = rows.first.find( ".table-cell:nth-child(1)").text
    (1...rows.count).each do |i|
         bank =  rows[i].find(".table-cell:nth-child(1)").text
         assert bank >= last_bank, "#{bank} >= #{last_bank}"
    end
    click_on "Bank"
    # I think I need this because of turbo
    sleep(1)
    rows = all(".table-row-group .table-row")
    last_bank = rows.first.find( ".table-cell:nth-child(1)").text
    (1...rows.count).each do |i|
        bank =  rows[i].find(".table-cell:nth-child(1)").text
        assert bank <= last_bank, "#{bank} <= #{last_bank}"
    end

  end
  test "should be able to sort by Name" do
    visit accounts_url
    assert_text "Accounts"

    click_on "Name"
    sleep(2)
    rows = all(".table-row-group .table-row")
    last_name = rows.first.find_all( ".table-cell")[1].text

    (1...rows.count).each do |i|
         name =  rows[i].find_all( ".table-cell")[1].text
         assert name >= last_name, "#{name} >= #{last_name}"
    end
    click_on "Name"
    # I think I need this because of turbo
    sleep(3)
    rows = all(".table-row-group .table-row")
    last_name = rows.first.find_all( ".table-cell")[1].text
    (1...rows.count).each do |i|
        name =  rows[i].find_all( ".table-cell")[1].text
        assert name <= last_name, "#{name} <= #{last_name}"
    end

  end
  test "should be able to sort by Number" do
    visit accounts_url
    click_on "Number"
    assert_text "New"

    rows = all(".table-row-group .table-row")
    last_number = rows.first.find_all(".table-cell")[2].text
    (1...rows.count).each do |i|
         number =  rows.first.find_all(".table-cell")[2].text
         assert number>= last_number, "#{number} >= #{last_number}"
    end
    click_on "Number"
    # I think I need this because of turbo
    assert_text "New"
    rows = all(".table-row-group .table-row")
    last_number = rows.first.find_all(".table-cell")[2].text
    (1...rows.count).each do |i|
        number = rows.first.find_all(".table-cell")[2].text
        assert number <= last_number, "#{number} <= #{last_number}"
    end

  end

  test "should be able to sort by checking" do
    visit accounts_url
    click_on "Checking"
    sleep 1
    rows = all(".table-row-group .table-row")
    last_value = rows.first.find(".table-cell:nth-child(4)").text
    (1...rows.count).each do |i|
         value= rows[i].find(".table-cell:nth-child(4)").text
         assert value >= last_value, "#{value} >= #{last_value}"
    end
    click_on "Checking"

    # I think I need this because of turbo
    sleep(1)
    rows = all(".table-row-group .table-row")
    last_value = rows.first.find(".table-cell:nth-child(4)").text
    (2...rows.count).each do |i|
        value= rows[i].find(".table-cell:nth-child(4)").text
        assert value <= last_value, "#{value} <= #{last_value}"
    end

  end



  test "should destroy Account from Accounts index" do
    skip 'Capabara seems to have problems when method is set in turbo data'

    visit accounts_url
    # We should have a row for each account
    count = Account.count
    assert_text "Delete", count: count
    accept_alert do
       click_on "Delete", match: :first
    end
    # we should have one less row
    assert_text "Delete", count: count-1
    assert_text "Account was successfully destroyed"
  end

  test "Show should show account" do #
    visit account_url(@account)
    assert_equal current_url, account_url(@account)
    assert_text @account.name
  end
  test "Show page should have filters" do
    visit account_url(@account)
    find("#toggle_filter").click

    assert_text "Date Range"
    assert_text "Amount Range"
    assert_text  "Payee"
    assert_text  "Check Range"
    assert_text  "Category"
  end
  test "Show should list the entries for the account" do
    visit account_url(@account)
    assert_equal @account.entries.count, find_all(".table-row-group .table-row").count
  end
  test "Show account should have an entry table with the correct headers" do
    visit account_url(@account)
    assert_text "Category"
    assert_text "Entrydate"
    assert_text "Check#"
    assert_text "Payee"
    assert_text "Memo"
    assert_text "Inflow"
    assert_text "Outflow"
    assert_text "Balance"
  end
  test "Show account should have an row in the entry table for each entry" do
    visit account_url(@account)
    count_in_db = @account.entries.count
    count_in_view = find_all(".table-row-group .table-row").count
    assert_equal count_in_db, count_in_view
  end
  test "Show each entry should have the correct data" do
    account = accounts(:discover)
    visit account_url(account)
    rows = find_all(".table-row-group .table-row")
    i = 0

    account.entries.normal_order.limit(10).each do |e|
      columns = rows[i].find_all('.table-cell')
      assert_equal e.category.name, columns[CATEGORY_COL].text if e.category
      assert_equal as(e.entry_date, :date), columns[DATE_COL].text
      assert_equal e.check_number.to_s, columns[CHECK_COL].text if e.check_number
      assert_equal e.payee, columns[PAYEE_COL].text if e.payee
      assert_equal e.memo, columns[MEMO_COL].text if e.memo
      assert_equal e.amount.to_f, columns[INFLOW_COL].text.tr('$,','').to_f if e.amount > 0
      assert_equal e.amount.abs.to_f, columns[OUTFLOW_COL].text.tr('$,','').to_f if e.amount < 0
      assert_equal e.balance.to_f, columns[BALANCE_COL].text.tr('$,','').to_f
      i += 1
    end
  end
  test "Show should be able to filter entries by Minumum Date" do
     visit account_url(@account)
     min_date =  Entry.group(:account_id).minimum("entry_date")[@account.id]
     find("#toggle_filter").click

     find("#date_after").fill_in(with: min_date + 1)
     click_on "Filter"
     expected  = @account.entries.where("entry_date >= ?", min_date + 1)
     sleep 2
     assert_equal expected.count, find_all(".table-row-group .table-row").count
     expected.each do |e|
       assert_text as(e.entry_date, :date)
       assert_text e.payee if e.payee
       assert_text e.memo  if e.memo
     end
  end
  test "Show should be able to filter entries by Maximum Date" do
     visit account_url(@account)
     max_date =  Entry.group(:account_id).maximum("entry_date")[@account.id]
     find("#toggle_filter").click

     find("#date_before").fill_in(with: max_date - 1)

     click_on "Filter"

     expected  = @account.entries.where("entry_date <= ?", max_date - 1)
     sleep 2

     assert_equal expected.count, find_all(".table-row-group .table-row").count
     expected.each do |e|
       assert_text as(e.entry_date, :date)
       assert_text e.payee if e.payee
       assert_text e.memo if e.memo
     end
  end
  test "Show should be able to filter by payee" do
    account = accounts(:discover)
    visit account_url(account)
    payee = "Stop &"
    find("#toggle_filter").click

    find("#payee_contains").fill_in(with: payee)
    click_on "Filter"
    expected = account.entries.payee_contains(payee)
    sleep 2
    assert_equal expected.count, find_all(".table-row-group .table-row").count
    expected.each do |e|
      assert_text as(e.entry_date, :date)
      assert_text e.payee
      assert_text e.memo  if e.memo
    end

  end
  test "Show should be able to filter by category" do
    account = accounts(:discover)
    visit account_url(account)
    category = categories(:groceries)
    find("#toggle_filter").click

    find("#category_is").select(category.name)
    click_on "Filter"
    expected = account.entries.category_is(category.id)
    sleep 2
    rows = find_all(".table-row-group .table-row")
    assert_equal expected.count, rows.count
    rows.each do |r|
      assert_equal category.name, r.find_all('.table-cell')[CATEGORY_COL].text
    end

  end
  test "Should be able to filter between check numbers" do
    account = accounts(:dcu_checking)
    visit account_url(account)

    max_check =  Entry.group(:account_id).maximum("check_number")[account.id]
    min_check =  Entry.group(:account_id).minimum("check_number")[account.id]

    find("#toggle_filter").click

    find("#check_after").fill_in(with: min_check + 1)


    find("#check_before").fill_in(with: max_check - 1)
    click_on "Filter"
    expected  = account.entries.where("check_number <= ? and check_number >= ?",
                                    max_check - 1, min_check + 1 )

    sleep 2
    assert_equal expected.count, find_all(".table-row-group .table-row").count
    expected.each do |e|
      assert_text as(e.entry_date, :date)
      assert_test e.check_number.to_s
      assert_text e.payee if e.payee
      assert_text e.memo  if e.memo
    end
  end

  # Pagination  TESTS
  test "A Max of ten account entries should be displayed" do
    account = accounts(:lots)
    visit account_url(account)
    expected = account.entries.normal_order.limit(10)
    assert_equal expected.count, find_all(".table-row-group .table-row").count
  end

  test "There should be a next button if there are more then 10 entries" do
    account = accounts(:lots)
    visit account_url(account)
    assert_text "Next"
  end

  test "next should take you to next entries" do
    account = accounts(:lots)
    visit account_url(account)
    expected = account.entries.normal_order.limit(10).offset(10)
    click_on "Next"
    assert_text "Previous"
    expected.each do |e|
      assert_text as(e.entry_date, :date)
      assert_text e.amount.abs.to_f.round(2).to_s
      assert_text e.payee if e.payee
      assert_text e.memo  if e.memo
    end

  end
  test "You should be able to work through all entries with next" do
    account = accounts(:lots)
    visit account_url(account)
    entries = account.entries.normal_order
    next_count = (entries.count / 10) - 1
    (1..next_count).each do |i|
      click_on "Next"
      assert_text "Previous"
      expected = entries.offset(10 * i).limit(10)
      expected.each do |e|
        assert_text as(e.entry_date, :date)
        assert_text e.amount.abs.to_f.round(2).to_s
        assert_text e.payee if e.payee
        assert_text e.memo  if e.memo
      end
    end
  end
  test "Next should work with filters" do
    account = accounts(:lots)
    visit account_url(account)
    assert_text "Payee"
    find("#toggle_filter").click

    fill_in "payee_contains", with: "Linguine"
    click_on "Filter"
    assert_text "Linguine", count:10
    entries = account.entries.normal_order.payee_contains("Linguine")
    next_count = (entries.count / 10) - 1
    (1..next_count).each do |i|
      click_on "Next"
      assert_text "Previous"
      expected = entries.offset(10 * i).limit(10)
      expected.each do |e|
        assert_text as(e.entry_date, :date)
        assert_text e.amount.abs.to_f.round(2).to_s
        assert_text e.payee if e.payee
        assert_text e.memo  if e.memo
      end
    end
  end
  test "You should be able to work through all entries with previous" do
    account = accounts(:lots)
    visit account_url(account)
    entries = account.entries.normal_order
    next_count = (entries.count / 10)
    (1..next_count).each do |i|
      click_on "Next page"
      assert_text "Previous page"
    end
    next_count.downto(1).each do |i|
      expected = entries.offset(10 * i).limit(10)
      expected.each do |e|
        assert_text as(e.entry_date, :date)
        assert_text e.amount.abs.to_f.round(2).to_s
        assert_text e.payee if e.payee
        assert_text e.memo  if e.memo
      end
      click_on "Previous page"
      assert_text "Next page"
    end
    assert_text "Previous", count: 0
  end

# END Pagination tests
  #  TODO: This test is too dependent on exact fixture data.
  # should be fixed
  test "Should be able to filter between dates" do
       account = accounts(:discover)
       visit account_url(account)

       max_date =  Date.today - 2
       min_date =  Entry.group(:account_id).minimum("entry_date")[account.id]
       find("#toggle_filter").click
       assert_text "Filter"
       find("#date_after").fill_in(with: min_date + 1)

       find("#date_before").fill_in(with: max_date - 1)
       click_on "Filter"

       expected  = account.entries.where("entry_date <= ? and entry_date >= ?",
                                       max_date - 1, min_date + 1 )
       sleep 2
       assert_equal expected.count, find_all(".table-row-group .table-row").count
       expected.each do |e|
         assert_text as(e.entry_date, :date)
         assert_text e.payee if e.payee
         assert_text e.memo  if e.memo
       end
  end
  test "should be able to link to account with filters" do
    filter_date = Date.today - 300
    visit account_url({id:@account.id, date_after: filter_date})
    find("#toggle_filter").click
    assert_equal filter_date.to_s, find("#date_after").value
  end
  test "New form cancel should link back to show page with filters" do
    filter_date_after = Date.today - 300
    filter_date_before = Date.today - 100
    visit account_url({id:@account.id,
      date_after: filter_date_after,
      date_before: filter_date_before})
    click_on 'New'
    assert_text 'Cancel'
    click_on 'Cancel'
    find("#toggle_filter").click

    assert_equal filter_date_after.to_s, find("#date_after").value
    assert_equal filter_date_before.to_s, find("#date_before").value
  end
  test "Create entry should return to show page with filters" do
    filter_date_after = Date.today - 300
    filter_date_before = Date.today - 2
    visit account_url({id:@account.id,
      date_after: filter_date_after,
      date_before: filter_date_before})
    click_on 'New'
    assert_text 'Cancel'
    category = categories(:groceries)
    find("#toggle_filter").click

    find("#entry_category_id").select(category.name)
    payee = "Money Taker Grocery Store"
    find("#entry_payee").fill_in(with: payee)

    find("#entry_entry_date").fill_in with: filter_date_before

    find("#entry_outflow").fill_in(with: "176.89")
    click_on "Save"
    assert_equal filter_date_after.to_s, find("#date_after").value
    assert_equal filter_date_before.to_s, find("#date_before").value
    assert_text payee
  end
  test "Edit Entry should show category even if it is inactive" do
    visit account_url(@account)
    # Set all categories inactive so we can test create
    # will still show categry even if it is inactive
    Category.all.each {|x| x.active = false; x.save}
    first_category = all(".table-row-group>.table-row").first.text.split.first
    row = find_all(".table-row")[1]
    category_cell = row.find('.table-cell[data-field="category_id"]')
    category_cell.click
    assert_text first_category

  end
  # This tests that after we edit an entry our filters are still the same.
  # 
  test "Should be able to edit Payee Inline" do
    visit account_url({id:@account.id})
    row = find_all(".table-row")[1]
    new_payee = "Change Payee $$$"
    payee_cell = row.find('.table-cell[data-field="payee"]')
    payee_cell.click
    payee_cell.set(new_payee)
    payee_cell.send_keys(:tab)
    refresh
    row = find_all(".table-row")[1]
    payee_cell = row.find('.table-cell[data-field="payee"]')
    assert_equal new_payee, payee_cell.text
  end



end
