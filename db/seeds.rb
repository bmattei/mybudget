# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

dcu_savings = Account.create(bank: 'DCU', name: 'DCU_SAVINGS', number: 20345690, has_checking: false)
dcu_checking = Account.create(bank: 'DCU', name: 'DCU_CHECKING', number: 20345691, has_checking: true)
dcu_long_term = Account.create(bank: 'DCU', name: 'DCU_LONG_TERM', number: 20345692, has_checking: false)
discover = Account.create(bank: 'Discover', name: 'Discover Card', number: 9566064545, has_checking: true)

transportation = Category.create(name:"transportation")
utilities = Category.create(name:"Utilities")
food = Category.create(name:"Food")
rv = Category.create(name:"RV")
gifts = Category.create(name:"Gifts")
income = Category.create(name:"Income")
auto_insurance = Category.create(name: "Auto Insurance", category: transportation)
gas = Category.create(name: "Gas", category:transportation)
auto_maintenance =  Category.create(name: "Auto Maintenance", category:transportation)
heating_oil =  Category.create(name: "Heating Oil", category: utilities)
electric =  Category.create(name: "Electric", category: utilities)
groceries =  Category.create(name: "Groceries", category: food)
restaurants = Category.create(name: "Restaurants", category: food)
rv_supplies = Category.create(name: "Supplies", category: rv)
rv_propane = Category.create(name: "Propane", category: rv)
rv_parks = Category.create(name: "Parks", category: rv)



num_entries = 200
check_number = 100
payees = [{name: "Shell", category: gas, account: discover, low: 20.00, high:125.00},
          {name: "Stop & Shop", category: groceries, account: discover , low:50.00, high: 250.00},
          {name: "Cobies", category: restaurants, account:discover, low: 25.00, high: 140.00},
          {name: "Pizza Shark", category: restaurants, account: discover, low: 15.00, high: 85.00},
          {name: "eversource", category: electric, account: dcu_checking, low: 55, high: 350.00},
          {name: "trader joes", category: groceries, account: discover, low: 74.00, high: 240.00},
          {name: "Market Basket", category: groceries, account: discover, low: 74.00, high: 240.00},
          {name: "Skp Benson", category: rv_parks, account: dcu_checking, low: 74.00, high: 800.00},
          {name: "SweetWater", category: rv_propane, account: dcu_checking, low: 34.00, high: 60.00},
          {name: "Exxon", category: gas, account: discover, low: 74.00, high: 240.00},
          {name: "Amazon", category: rv_supplies, account: discover, low: 74.00, high: 240.00},
          {name: "Amazon", category: rv_supplies, account: discover, low: 74.00, high: 240.00},
          {name: "Amazon", category: rv_supplies, account: discover, low: 74.00, high: 240.00},
          {name: "Amazon", category: gifts, account: discover, low: 74.00, high: 240.00},
          {name: "Chipolte", category: restaurants, account: discover, low: 24.00, high: 60.00},
          {name: "A1 Auto", category: auto_maintenance, account: discover, low: 44.00, high: 540.00},
          {name: "Linguines", category: restaurants, account: discover, low: 24.00, high: 140.00},
          {name: "SweetWater", category: income, account: dcu_checking, low: 100.00, high: 300.00},
          {name: "Retirement Money", category: income, account: dcu_checking, low: 1500, high: 3000}
        ]

Entry.create(account: discover, entry_date: Date.today - 10, payee: "Hartford Ins", amount: -587.00, category: auto_insurance)
(0...num_entries).each do |i|
   payee = payees[rand(payees.count - 1)]
   account = payee[:account]
   num = nil
   if account.name == dcu_checking
      num = check_number
      check_number += 1
   end
   amount = (rand(payee[:high]) + rand(payee[:low]))
   amount = -amount if payee[:category] != income
   Entry.create(account: account,
                entry_date: Date.today - (num_entries - i),
                check_number: num,
                payee: payee[:name],
                amount: amount,
                category: payee[:category])
end
