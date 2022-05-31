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
    assert_text "Accounts", wait: 5
    find(".table-row-group").click_on "Edit", match: :first

    assert_text "Editing account", wait: 5
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
    assert_text "New"
    rows_count = all(".table-row-group>.table-row").count
    last_number = all( ".table-row-group>.table-row:nth-child(1)>.table-cell:nth-child(3)").first.text
    (2..rows_count).each do |i|
         number =  all( ".table-row-group>.table-row:nth-child(#{i})>.table-cell:nth-child(3)").first.text
         assert number>= last_number, "#{number} >= #{last_number}"
    end
    click_on "Number"
    # I think I need this because of turbo
    assert_text "New"

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
    account.entries.order(entry_date: :asc).each do |e|
      columns = rows[i].find_all('.table-cell')
      assert_equal e.category.name, columns[0].text if e.category.name
      assert_equal e.entry_date.to_s, columns[1].text
      assert_equal e.check_number.to_s, columns[2].text if e.check_number
      assert_equal e.payee, columns[3].text if e.payee
      assert_equal e.memo, columns[4].text if e.memo
      assert_equal e.amount.to_f, columns[5].text.tr('$,','').to_f if e.amount > 0
      assert_equal e.amount.abs.to_f, columns[6].text.tr('$,','').to_f if e.amount < 0
      assert_equal e.balance.to_f, columns[7].text.tr('$,','').to_f
      i += 1
    end
  end
  test "Show should be able to filter entries by Minumum Date" do
     visit account_url(@account)
     min_date =  Entry.group(:account_id).minimum("entry_date")[@account.id]
     find("#date_after").fill_in(with: min_date + 1)
     click_on "Filter"
     expected  = @account.entries.where("entry_date >= ?", min_date + 1)
     sleep 2
     assert_equal expected.count, find_all(".table-row-group .table-row").count
     expected.each do |e|
       assert_text e.entry_date.to_s
       assert_text e.payee if e.payee
       assert_text e.memo  if e.memo
     end
  end
  test "Show should be able to filter entries by Maximum Date" do
     visit account_url(@account)
     max_date =  Entry.group(:account_id).maximum("entry_date")[@account.id]
     find("#date_before").fill_in(with: max_date - 1)

     click_on "Filter"

     expected  = @account.entries.where("entry_date <= ?", max_date - 1)
     sleep 2

     assert_equal expected.count, find_all(".table-row-group .table-row").count
     expected.each do |e|
       assert_text e.entry_date.to_s
       assert_text e.payee if e.payee
       assert_text e.memo if e.memo
     end
  end
  test "Show should be able to filter by payee" do
    account = accounts(:discover)
    visit account_url(account)
    payee = "Stop &"
    find("#payee_contains").fill_in(with: payee)
    click_on "Filter"
    expected = account.entries.payee_contains(payee)
    sleep 2
    assert_equal expected.count, find_all(".table-row-group .table-row").count
    expected.each do |e|
      assert_text e.entry_date.to_s
      assert_text e.payee
      assert_text e.memo  if e.memo
    end

  end
  test "Show should be able to filter by category" do
    account = accounts(:discover)
    visit account_url(account)
    category = categories(:groceries)
    find("#category_is").select(category.name)
    click_on "Filter"
    expected = account.entries.category_is(category.id)
    sleep 2
    rows = find_all(".table-row-group .table-row")
    assert_equal expected.count, rows.count
    rows.each do |r|
      assert_equal category.name, r.find_all('.table-cell')[0].text
    end

  end
  test "Should be able to filter between check numbers" do
    account = accounts(:dcu_checking)
    visit account_url(account)

    max_check =  Entry.group(:account_id).maximum("check_number")[account.id]
    min_check =  Entry.group(:account_id).minimum("check_number")[account.id]

    find("#check_after").fill_in(with: min_check + 1)


    find("#check_before").fill_in(with: max_check - 1)
    click_on "Filter"
    expected  = account.entries.where("check_number <= ? and check_number >= ?",
                                    max_check - 1, min_check + 1 )

    sleep 2
    assert_equal expected.count, find_all(".table-row-group .table-row").count
    expected.each do |e|
      assert_text e.entry_date.to_s
      assert_test e.check_number.to_s
      assert_text e.payee if e.payee
      assert_text e.memo  if e.memo
    end
  end
  test "Should be able to filter between dates" do
       account = accounts(:discover)
       visit account_url(account)

       max_date =  Entry.group(:account_id).maximum("entry_date")[account.id]
       min_date =  Entry.group(:account_id).minimum("entry_date")[account.id]

       find("#date_after").fill_in(with: min_date + 1)


       find("#date_before").fill_in(with: max_date - 1)
       click_on "Filter"
       expected  = account.entries.where("entry_date <= ? and entry_date >= ?",
                                       max_date - 1, min_date + 1 )

       sleep 2
       assert_equal expected.count, find_all(".table-row-group .table-row").count
       expected.each do |e|
         assert_text e.entry_date.to_s
         assert_text e.payee if e.payee
         assert_text e.memo  if e.memo
       end
  end

end
