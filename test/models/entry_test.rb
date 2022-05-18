require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "Balances should be calculated" do
    Entry.all.each do |e|
      assert_not_nil e.balance
    end
  end
  test "balance should be correct" do
    assert_equal  5000, entries(:dcu_checking_init).balance
    assert_equal  4900, entries(:dcu_checking_buy_gas_1).balance
    assert_equal  4800, entries(:dcu_checking_buy_gas_2).balance
    assert_equal  4700, entries(:dcu_checking_buy_gas_3).balance

  end
  test 'Balances should updated correctly when an new entry is created' do
    amount = -10.00
    entry_date = entries(:dcu_checking_init).entry_date

    entry = Entry.create(account: accounts(:dcu_checking),
                         category: categories(:restaurants),
                         payee: 'linguines',
                         amount: amount,
                         entry_date: entry_date)
    assert_not_nil entry
    assert_equal entry.balance.to_f, 4990.to_f
    assert_equal entries(:dcu_checking_buy_gas_1).balance.to_f, 4890.to_f
    assert_equal entries(:dcu_checking_buy_gas_2).balance.to_f, 4790.to_f
    assert_equal entries(:dcu_checking_buy_gas_3).balance.to_f, 4690.to_f
  end
  test 'Balances should updated correctly when an entry is updated' do
    e = entries(:dcu_checking_init)
    e.amount = 10000
    e.save
    assert_equal entries(:dcu_checking_buy_gas_1).balance.to_f, 9900.to_f
    assert_equal entries(:dcu_checking_buy_gas_2).balance.to_f, 9800.to_f
    assert_equal entries(:dcu_checking_buy_gas_3).balance.to_f, 9700.to_f
  end

  test "creating and transfer should create two entries" do
    amount = -1000
    from_account = accounts(:dcu_checking)
    to_account = accounts(:discover)
    memo =  "OUR TRANSFER MEMO"
    before_count = Entry.count
    Entry.create(entry_date: Date.today,
                         account: from_account,
                         transfer_account: to_account,
                         memo: memo,
                         amount: amount)
     assert_equal before_count + 2, Entry.count
     from_entry = from_account.entries.last
     to_entry = to_account.entries.last
     assert_equal amount, from_entry.amount
     assert_equal (-amount), to_entry.amount
     assert_equal from_entry.entry_date, to_entry.entry_date
     assert_equal from_entry.memo, to_entry.memo
     assert_equal to_account.id, to_entry.account.id
     assert_equal from_account.id, from_entry.account.id
     assert_equal from_account.id, to_entry.transfer_account_id
     assert_equal to_account.id, from_entry.transfer_account_id
     assert_equal from_entry.id, to_entry.transfer_entry_id
     assert_equal to_entry.id, from_entry.transfer_entry_id

  end



end
