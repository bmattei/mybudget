require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "Balances should be calculated" do
    Entry.all.each do |e|
      assert_not_nil e.balance
    end
  end
  test "balance should be correct" do
    assert_equal entries(:dcu_checking_init).balance, 5000
    assert_equal entries(:dcu_checking_buy_gas_1).balance, 4900
    assert_equal entries(:dcu_checking_buy_gas_2).balance, 4800
    assert_equal entries(:dcu_checking_buy_gas_3).balance, 4700

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



end
