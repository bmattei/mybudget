    $LOAD_PATH << '.'
    $LOAD_PATH << './etl'
    require 'config/environment'
class CategoryMap
    def create_new_cats
    business = Category.find_or_create_by(name: "BUSINESS", active: true)
    [:lisa_expenses, :bob_expenses, :lisa_revenue, :bob_revenue].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: business)
    end
    communications = Category.find_or_create_by(name: "COMMUNICATIONS", active: true)
    [:phones, :cell, :internet].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: communications)
    end
    education = Category.find_or_create_by(name: "EDUCATION", active: true)
    [:college, :highschool, :education_misc].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: education)
    end
    entertainment = Category.find_or_create_by(name: "ENTERTAINMENT", active: true)
    [:passes, :attractions, :guitar, :plants,  :services, :hotels, :entertainment_misc].each do |sub_cat|
      Category.find_or_create_by(name:sub_cat.to_s, category: entertainment)
    end
    food   = Category.find_or_create_by(name: "FOOD", active: true)
    [:groceries, :restaurants].each do |sub_cat|
       Category.find_or_create_by(name:sub_cat.to_s, category: food);
    end
    household = Category.find_or_create_by(name: "HOUSEHOLD", active: true)
    [:maintenance, :supplies, :storage, :furniture, :kitchen_items, :plants, :home_insurance, :items_misc, :laundry, :expenses_misc,
                :electronics, :pets, :alyssa].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: household)
    end
    gifts = Category.find_or_create_by(name: "GIFTS", active: true)
    [:new_charity, :financial_help, :gifts_friends_and_family, :gifts_misc].each do |sub_cat|
      Category.find_or_create_by(name:sub_cat.to_s, category: gifts)
    end
    health = Category.find_or_create_by(name: "HEALTH", active: true)
    [:doctors, :hospitals, :prescriptions, :non_prescriptions, :health_insurance, :gym_membership, :health_misc].each do |sub_cat|
      Category.find_or_create_by(name:sub_cat.to_s, category: health);
    end
    income = Category.find_or_create_by(name: "INCOME", active: true)
    [:salary,  :retirement, :income_misc].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: income)
    end
    loans = Category.find_or_create_by(name: "LOANS", active: true)
    [:personal_loans, :mortgage, :heloc].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: loans)
    end
    personal = Category.find_or_create_by(name: "PERSONAL", active: true)
    [:clothes, :personal_misc].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: personal)
    end
    rent = Category.find_or_create_by(name: "RENT", active: true)
    [:long_term_stays, :campgrounds, :rv_clubs].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: rent)
    end
    taxes = Category.find_or_create_by(name: "TAXES", active: true)
    [:income_tax_state, :income_tax_federal, :real_estate_tax].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: taxes)
    end
    transportation = Category.find_or_create_by(name: "TRANSPORTATION", active: true)
    [:rv_gas, :auto_gas, :rv_insurance, :auto_insurance,:rv_maintenance, :auto_registration, :rv_registration,
      :auto_maintenance, :tolls, :rv_excise, :auto_excise, :license_renewal,
      :parking, :planes_trains_buses, :transportation_misc, :auto_sales_tax, :auto_purchase, :rv_purchase, :rv_sales_tax].each do |sub_cat|
          Category.find_or_create_by(name:sub_cat.to_s, category: transportation)
    end
    utilities = Category.find_or_create_by(name: "UTILITIES", active: true)
    [:propane, :heating_oil, :heating_gas, :electric, :water, :utils_misc].each do |sub_cat|
      Category.find_or_create_by(name:sub_cat.to_s, category: utilities)
    end

    end
    def map_cats

    map_cat = {"Lisa Business : Fees"=> "lisa_expenses",
     "Recreation : Entertainment"=> "entertainment_misc",
     "Charity"=> "new_charity",
     "Housing : Real Estate Tax"=>"real_estate_tax",
     "RV : Laundry"=> "laundry",
     "Housing : Supplies"=> "supplies",
     "Lisa Business : Insurance"=> "lisa_expenses",
     "Housing : Water"=> "water",
     "RV : excise tax"=> "rv_excise",
     "Personal : BankFee"=> "expenses_misc",
     "Lisa Business : Office supplies"=> "lisa_expenses",
     "Income Tax : Estimated"=> "income_tax_federal",
     "Housing : Phone & Internet"=>"cell",
     "Recreation : Vacation"=>"entertainment_misc",
     "RV : clubs"=> "rv_clubs",
     "Lisa Business : Membrships"=> "lisa_expenses",
     "Housing : Cell Phones"=> "phones",
     "Lisa Business : Parking"=>"lisa_expenses",
     "Recreation : Hotel"=>"hotels",
     "Lisa Business : Income"=>"lisa_revenue",
     "Transportation : Car Payment"=>"auto_purchase",
     "Loans : HALOC Interest Payment"=>"heloc",
     "income : misc"=>"income_misc",
     "Transportation : tolls"=>"tolls",
     "Housing : Dog"=>"pets",
     "Lisa Business : Contract Work"=>"lisa_revenue",
     "Lisa Business : Cost of Goods Sold"=>"lisa_expenses",
     "Initial Balance"=> "expenses_misc",
     "Lisa Business : Business expenses"=>"lisa_expenses",
     "income tax : federal"=>"income_tax_federal",
     "Housing : House/Rental Insurance"=> "home_insurance",
     "Housing : Maintenance & Repairs"=>"maintenance",
     "RV : Maintenance"=>'rv_maintenance',
     "Personal : cloths"=>"clothes",
     "Personal : nom-prescription medication"=>"non_prescriptions",
     "Education : College"=> "college",
     "Lisa Business : Advertizing"=>"lisa_expenses",
     "Lisa Business : Misc"=>"lisa_expenses",
     "Financial Help : Alyssa"=>"financial_help",
     "Personal : Health Insurance"=>"health_insurance",
     "RV : Equipment/Supplies"=>"supplies",
     "Housing : Storage"=> "storage",
     "Personal : Gifts"=>"gifts_friends_and_family",
     "Recreation : His"=>"entertainment_misc",
     "expense : misc"=> "expenses_misc",
     "Recreation : Alyssa Horse"=>"alyssa",
     "Recreation : Hers"=>"entertainment_misc",
     "Personal : Miscellaneous"=>"expenses_misc",
     "Food : Groceries"=>"groceries",
     "Income : Available next month"=>"income_misc",
     "Transportation : Car Insurance"=>"auto_insurance",
     "Personal : Prescriptions, Medicine"=>"prescriptions",
     "RV : PURCHASE"=>"rv_purchase",
     "RV : Campgrounds"=>"campgrounds",
     "Personal : Doctor, Dentist"=>"doctors",
     "Financial Help : Mom And Dad"=>"financial_help",
     "Recreation : Alyssa"=>"alyssa",
     "RV : Tolls"=>"tolls",
     "Transportation : Repairs & Maintenance"=> "auto_maintenance",
     "RV : Cell Phones and Data"=> "cell",
     "business (bob) : computer"=>"bob_expenses",
     "RV : propane"=>"propane",
     "income tax : state"=> "income_tax_state",
     "Lisa Business : Education"=>"lisa_expenses",
     "Transportation : Auto Excise"=>"auto_excise",
     "Housing : Electricity"=>"electric",
     "Lisa Business : Supplies Hardware"=>"lisa_expenses",
     "Charity : Other"=>"new_charity",
     "Personal : Fitness"=>"personal_misc",
     "Transportation : Air/train/bus/etc"=>"planes_trains_buses",
     "RV : Hotel"=>"hotels",
     "Food : Restaurants"=>"restaurants",
     "Lisa Business : Supplies"=>"lisa_expenses",
     "RV : MISC"=>"expenses_misc",
     "Transportation : Parking"=>"parking",
     "Personal : BankCredit"=> "expenses_misc",
     "Loans : Loan Karina"=>"personal_loans",
     "Housing : Garden"=>"plants",
     "Housing : Gas"=>"heating_gas",
     "Income : Available this month"=>"income_misc",
     "Financial Help : Matteis"=>"financial_help",
     "Loans : LoanAlyssa"=>"personal_loans",
     "Transportation : Registration"=>"auto_registration",
     "RV : gasoline"=> "rv_gas",
     "Lisa Business : Bank Fees"=>"lisa_expenses",
     "Transportation : Gas"=> "auto_gas"}

     #map_cat.keys.each do  |key|
    #   puts key
  #     Category.where(name: key ).first  || raise( "#{key} not found")
#     end
     map_cat.values.each do  |value|
       puts value
       Category.where(name: value ).first  || raise( "#{value} not found")
     end
     map_cat.each do  |key, value|
        old_cat = Category.where(name: key ).first  # || raise( "#{key} not found")
        new_cat = Category.where(name: value ).first  || raise( "#{value} not found")

        if old_cat
          puts "#{old_cat.name.ljust(30)} #{new_cat.name}"
          Entry.where(category_id: old_cat.id).update_all(category_id: new_cat.id)
          old_cat.delete

        end
     end



    end

end
    if __FILE__ == $0

      mapper = CategoryMap.new
      mapper.create_new_cats
      mapper.map_cats
    end
