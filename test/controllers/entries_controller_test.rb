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
    get new_entry_url
    assert_response :success
  end

  test "should create entry" do

    assert_difference("Entry.count") do
      post entries_url,
      params: { entry: { amount: 111.55,
                        account_id: accounts(:dcu_checking).id,
                        category_id: categories(:groceries).id,
                        entry_date: Date.today - 155 ,
                        payee: "Amazon"} }
    end

    assert_redirected_to entries_url
  end


  test "should get edit" do
    get edit_entry_url(@entry)
    assert_response :success
  end

  test "should update entry" do
    patch entry_url(@entry), params: { entry: {
      account: accounts(:dcu_checking),
      amount: 987.68,
      category: categories(:auto_maintenance),
      entry_date: Date.today-10,
      payee: "A1 Auto",
    } }
    assert_redirected_to entries_url
  end

  test "should destroy entry" do
    assert_difference("Entry.count", -1) do
      delete entry_url(@entry)
    end

    # assert_redirected_to entries_url
  end
end
