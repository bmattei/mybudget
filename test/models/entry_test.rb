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

  test "Should create two entries when a transfer is created" do
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
  test "Should update transaction balances when a transfer is created" do
    amount = -1000
    from_account = accounts(:dcu_checking)
    to_account = accounts(:discover)
    from_account_saved_balances = from_account.entries.collect {|e|  {id: e.id, balance: e.balance} }
    to_account_saved_balances = to_account.entries.collect {|e|  {id: e.id, balance: e.balance} }

    # Date is picked to proceed all other entries
    new_from_entry = Entry.create(entry_date: Date.today - 1000,
                         account: from_account,
                         transfer_account: to_account,
                         amount: amount)
    from_account_saved_balances.each do |h|
      entry = Entry.find(h[:id])
      assert_equal (h[:balance] + amount).to_f, entry.balance.to_f, entry.as_json.to_s
    end
    to_account_saved_balances.each do |h|
      entry = Entry.find(h[:id])
      assert_equal (h[:balance] - amount).to_f, entry.balance.to_f, entry.as_json.to_s
    end
    assert_equal amount.to_f, new_from_entry.balance.to_f

    assert_equal (-amount.to_f), new_from_entry.transfer_entry.amount.to_f
  end
  test "Should update both sides of transfer when a transfer is updated" do
    amount = -1000
    from_account = accounts(:dcu_checking)
    to_account = accounts(:discover)


    # Date is picked to proceed all other entries
    entry = Entry.create(entry_date: Date.today - 1000,
                         account: from_account,
                         transfer_account: to_account,
                         amount: amount)
    new_amount = 1500
    entry.amount = new_amount
    entry.save
    assert_equal new_amount, entry.amount
    assert_equal (-new_amount), entry.transfer_entry.amount
  end
  test "should delete both entries when a transfer is deleted" do
    amount = -1000
    from_account = accounts(:dcu_checking)
    to_account = accounts(:discover)


    # Date is picked to proceed all other entries
    entry = Entry.create(entry_date: Date.today - 1000,
                         account: from_account,
                         transfer_account: to_account,
                         amount: amount)

    assert_equal 1, Entry.where(id: entry.id).count
    assert_equal 1,  Entry.where(id: entry.transfer_entry_id).count

    entry.destroy
    assert_equal 0, Entry.where(id: entry.id).count
    assert_equal 0,  Entry.where(id: entry.transfer_entry_id).count
  end
  test "Should delete the transfer entry (in other account) when transfer is changed to a non tranfer transaction" do
    amount = -1000
    from_account = accounts(:dcu_checking)
    to_account = accounts(:discover)


    # Date is picked to proceed all other entries
    entry = Entry.create(entry_date: Date.today - 1000,
                         account: from_account,
                         transfer_account: to_account,
                         amount: amount)
    assert entry
    transfer_entry = entry.transfer_entry
    assert transfer_entry

    entry.update(transfer_account_id: nil, category: categories(:auto_maintenance),
                                payee: "A1 Auto")

    assert_nil entry.transfer_account_id, "transfer_account_id not nil"
    assert_nil entry.transfer_entry_id, "transfer_entry_id not nil"

    assert Entry.where(id:transfer_entry.id).count, 0
  end
  test "Should add  an entry when entry  is changed to a tranfer transaction" do
    amount = -100
    entry = Entry.create(account: accounts(:dcu_checking),
                         category: categories(:restaurants),
                         payee: 'linguines',
                         amount: amount,
                         entry_date: Date.today - 44)
     assert_not_nil entry
     before_count = Entry.count
     entry.update(category: nil, payee: nil, amount: amount, transfer_account: accounts(:discover))

     after_count = Entry.count
     assert_equal before_count + 1, after_count
     entry.reload
     transfer_entry = entry.transfer_entry
     assert_not_nil transfer_entry
     assert_equal (-amount), transfer_entry.amount

  end
  test "Should balances should be correct when an entry is changed to a transfer" do
    amount = -100
    entry = Entry.create(account: accounts(:dcu_checking),
                         category: categories(:restaurants),
                         payee: 'linguines',
                         amount: amount,
                         entry_date: Date.today - 44)
     entry.update(category: nil, payee: nil, amount: amount, transfer_account: accounts(:discover))
     Entry.all.each do |e|
       calc_balance = e.account.entries.
                           where("entry_date < ? or (entry_date = ? and (amount > ? or (amount = ? and id <= ?)))",
                                 e.entry_date, e.entry_date, e.amount, e.amount, e.id).sum(:amount)
       assert_equal calc_balance.to_f, e.balance.to_f
     end
  end
  test "Should balances should be correct when an entry is changed from a transfer" do
    amount = -1000
    from_account = accounts(:dcu_checking)
    to_account = accounts(:discover)

    # Date is picked to proceed all other entries
    entry = Entry.create(entry_date: Date.today - 1000,
                         account: from_account,
                         transfer_account: to_account,
                         amount: amount)

    entry.update(transfer_account_id: nil, category: categories(:auto_maintenance),
                                payee: "A1 Auto")
    Entry.all.each do |e|
      calc_balance = e.account.entries.
                            where("entry_date < ? or (entry_date = ? and (amount > ? or (amount = ? and id <= ?)))",
                                        e.entry_date, e.entry_date, e.amount, e.amount, e.id).sum(:amount)
      assert_equal calc_balance.to_f, e.balance.to_f
    end

  end





end
