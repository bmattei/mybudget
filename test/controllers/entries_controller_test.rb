require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @entry = entries(:dcu_checking_init)
  end
  test "should get index" do
    get entries_url
    assert_response :success
  end

  test "should get new" do
    get new_entry_url(account_id: @entry.account_id)
    assert_response :success
  end

  test "should create entry" do
    assert_difference("Entry.count") do
      post entries_url,
      params: { entry: {inflow: 111.55,
                        account_id: accounts(:dcu_checking).id,
                        category_id: categories(:groceries).id,
                        entry_date: Date.today - 155 ,
                        payee: "Amazon"} }
    end

  end


  test "Should Not create any entries if outflow or inflow is not set" do
    before_count = Entry.count
    post entries_url,
      params: { entry: {
                        account_id: accounts(:dcu_checking).id,
                        category_id: categories(:groceries).id,
                        entry_date: Date.today - 155 ,
                        payee: "Amazon"} }

    assert_equal before_count, Entry.count
    assert_response(422)
  end
  test "Should Not create any entries if account is not set" do
    skip "not sure what the correct behavior is here"
    before_count = Entry.count
    post entries_url,
      params: { entry: {
                        outflow: 100,
                        category_id: categories(:groceries).id,
                        entry_date: Date.today - 155 ,
                        payee: "Amazon"} }

    assert_equal before_count, Entry.count
    assert_response(422)
  end

  test "should create new transfer entry" do
    to_a = accounts(:discover)
    from_a = accounts(:dcu_checking)
    amount = 300
    entry_date = Date.today - 155
    to_count = to_a.entries.count
    from_count  = from_a.entries.count
    post entries_url,
    params: { entry: { outflow: amount,
                        account_id: from_a.id,
                        transfer_account_id: to_a.id,
                        entry_date: entry_date,
                        memo: "No one would use this memo"
                      } }
    assert_equal from_count + 1, from_a.entries.count
    assert_equal to_count + 1, to_a.entries.count

    to_e = to_a.entries.last
    from_e = from_a.entries.last
    assert_equal (-amount), from_e.amount
    assert_equal (amount), to_e.amount
    assert_equal entry_date, to_e.entry_date
    assert_equal from_e.account_id, to_e.transfer_account_id
    assert_equal to_e.account_id, from_e.transfer_account_id
    assert_equal to_e.id, from_e.transfer_entry_id
    assert_equal from_e.id, to_e.transfer_entry_id
  end


  test "should get edit" do
    get edit_entry_url(@entry)
    assert_response :success
  end

  test "should update entry" do
    patch entry_url(@entry), params: { entry: {
      account: accounts(:dcu_checking),
      outflow: 987.68,
      category: categories(:auto_maintenance),
      entry_date: Date.today-10,
      payee: "A1 Auto",
    } }
    assert_redirected_to account_url(accounts(:dcu_checking))
  end

  test "should destroy entry" do
    assert_difference("Entry.count", -1) do
      delete entry_url(@entry)
    end

    # assert_redirected_to entries_url
  end
end
