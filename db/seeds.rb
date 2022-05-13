# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Account.create([{bank: 'DCU', name: 'DCU_SAVINGS', number: 20345690, has_checking: false},
                 {bank: 'DCU', name: 'DCU_CHECKING', number: 20345691, has_checking: true},
                 {bank: 'DCU', name: 'DCU_LONG_TERM', number: 20345692, has_checking: false},
                 {bank: 'Discover', name: 'Discover Card', number: 9566064545, has_checking: true},
              ])
transportation = Category.create(name:"transportation")
utilities = Category.create(name:"Utilities")

Category.create([{name: "Auto Insurance", category:transportation},
                {name: "Gas", category:transportation},
                {name: "Auto Maintenance", category:transportation},
                {name: "Heating Oil", category: utilities},
                {name: "Electric", category: utilities}]
              )
