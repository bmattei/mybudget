$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
class LoadDisentriesIntoEntries

  def initialize(real_deal: false, initial_date: Date.new(2015,5,14), initial_balance: -1797.58,
                 expected_balance: -3955.26)

    @initial_date = initial_date
    @initial_balance = initial_balance
    @real_deal = real_deal
    @expected_balance = expected_balance
    @balance = @initial_balance
    @discover =  Account.where(name: "Discover Card").first|| raise("Bad Account")
    @dcu_checking =  Account.where(name: "DCU CHECKING").first|| raise("Bad Account")

    @category_initial_balance = Category.where(name: "Initial Balance").first ||  raise("Bad Category")

    @auto_gas = Category.where(name:"Transportation : Gas").first || raise("Bad Cat")
    @auto_maint = Category.where(name: "Transportation : Repairs & Maintenance").first || raise("Bad Cat")
    @campgrounds = Category.where(name: "RV : Campgrounds").first || raise("Bad Cat")
    @charity = Category.where(name: "Charity : Other").first || raise("Bad Cat")
    @cloths = Category.where(name: "Personal : cloths").first || raise("Bad Cat")
    @entertainment = Category.where(name: "Recreation : Entertainment").first || raise("Bad Cat")
    @gifts = Category.where(name:"Personal : Gifts").first || raise("Bad Cat")
    @groceries = Category.where(name:"Food : Groceries").first || raise("Bad Cat")
    @hotel = Category.where(name: "RV : Hotel").first || raise("Bad Cat")
    @medical = Category.where(name:"Personal : Doctor, Dentist").first || raise("Bad Cat")
    @misc_expense = Category.where(name:"expense : misc").first || raise("Bad Cat")
    @parking = Category.where(name: "Transportation : Parking").first || raise("Bad Cat")
    @personal_misc = Category.where(name: "Personal : Miscellaneous").first || raise("Bad Cat")
    @restaurant = Category.where(name: "Food : Restaurants").first || raise("Bad Cat")
    @rv_gas = Category.where(name: "RV : gasoline").first || raise("Bad Cat")
    @rv_maint = Category.where(name: "RV : Maintenance").first || raise("Bad Cat")
    @rv_supplies = Category.where(name:"RV : Equipment/Supplies").first || raise("Bad Cat")
    @dog = Category.where(name:"Housing : Dog").first || raise("Bad Cat")
    @financial_help_md = Category.where(name:"Financial Help : Mom And Dad").first || raise("Bad Cat")
    @landry = Category.where(name:"RV : Laundry").first || raise("Bad Cat")
    @prescriptions = Category.where(name:"Personal : Prescriptions, Medicine").first || raise("Bad Cat")
    @air_travel = Category.where(name: "Transportation : Air/train/bus/etc").first || raise("Bad Cat")
    @tolls = Category.where(name: "Transportation : tolls").first || raise("Bad Cat")

    @map_cat = {
      "Supermarkets" => @groceries,
      "Restaurants" => @restaurant,
      "Medical Services" => @medical,
      "Automotive" => @auto_maint
      }
  end
  def map_to_app_category(payee, input_category, amount)
    # only going to do easy matcher everything else will go in a misc expense
    # or credit
    #

    category = @map_cat[input_category]

    if category.nil?
      case input_category
      when "Gasoline"
        category = amount.abs > 60 ? @rv_gas : @auto_gas
      when "Travel/Entertainment"
        case payee
        when /(jetblue|SUNCOUNTRY DIRECT|ENTERPRISE C|KEYS SHUTTLE|KNIGHTS AIR|AMERICANAIR|PLYMOUTH AND B|508-746-0378|LA METRO|AIRLINES|DOLLAR CAR|SW AIR|VIRGIN ATLANTIC|ALAMO CAR|COMMUTER RAIL)/i
            category = @air_travel
        when /(BW THUNDERBIRD|EMERALD FOREST|HOLIDAY RVS|PASS CAMP|BUFFALO GAP|LAJITAS GOLF|BRIARCLIFFE|campground|RECREATION.GOV|rv resort|SAVANNAS REC|wilder - |rv park|camp out|red oaks|SWEET WATER FOREST|Camping| KOA |PONTCHARTRAIN LANDING|WILDER - RICE)/i
            category = @campgrounds
        when /(hotel|AIRBNB|Holiday Inn|HOUMD PMS|ATHENA INN|Marriot|Super 8| INN |SUBURBAN EXTENDED)/i
             category = @hotel
        when /(Parking|LOGAN PK|PRKNG LONG)/i
             category = @parking
        when /(seafood|EMPANADA|linguini|Dunkin|ice cream|restaurant|Panera Bread|Hillside Grille|TRATTORIA| CAFE )/i
                 category = @restaurant
        when /(sunpass|MASSPIKE|^TOLLS | tolls | toll |E-ZPASS)/i
            category = @tolls
        else
          category = @entertainment
        end
      end
    end

    if category.nil?
      case payee
      when /DIRECTPAY FULL/i
           category = nil
      when /(BRIARCLIFFE|State Park|campground|RECREATION.GOV|rv resort|SAVANNAS REC|wilder - |rv park|camp out|red oaks|SWEET WATER FOREST|Camping| KOA |PONTCHARTRAIN LANDING|WILDER - RICE)/i
          category = @campgrounds
      when /(KOHL|HIBBETT|shoe|BEALLS|SPORTSWEAR|LLBEAN|MARSHALLS #|ROSS STORES)/i
            category = @cloths
      when /(CARINGBRIDGE|WWW.LLS.ORG|SAVE THE CHILDREN|Partners in Health|LEUKEMIA RESEARCH)/i
            category = @charity
      when /( pets )/i
          category = @dog
      when /( RECREATION |YOGA|EVERGLADES NP|THEATRES |BREATHE WELLNESS|brookgreen gardens|BARNES.NOBLE.COM|skillshare|Natural Bridge|itunes|REDBOX|apple\.com|netflix|ESPN|Museu|Tower Hill|Botanic Gard|NYTIMES)/i
          category =  @entertainment
      when /(GREATCALL)/i
            category =  @financial_help_md
      when /(shell)/i
            category = amount.abs > 60 ? @rv_gas : @auto_gas
      when  /(Shutterfly|Redbubble|CTS STORE|HOBBY-LOBBY|nancys candy)/i
        category =  @gifts
      when /(sprouts farmers|Kroger)/i
        category = @groceries
      when /(hotel|Holiday Inn|HOUMD PMS|ATHENA INN|Marriot|Super 8| INN )/i
         category = @hotel
      when /laundry/i
          category = @landry
      when /(Hospital)/i
         category = @medical
       when /(Parking|LOGAN PK|PRKNG LONG)/i
         category = @parking
      when /intuit/i
          category = @personal_misc
      when /CORNERSTONE HEALTH/i
          category = @prescriptions
      when /(seafood|EMPANADA|linguini|Dunkin|ice cream|restaurant|Panera Bread|Hillside Grille|TRATTORIA)/i
             category = @restaurant
      when / ( RV )/i
        category = @rv_maint
      when /(Walmart|lowe's|CVS\/PHARMACY|amazon|AMZN MKTP|USPS|Walgreens|ocean state|tractor supply)/i
        category = @rv_supplies
      else
          category = @misc_expense
      end
    end
    return category
  end
  def cleanup_before_import
    delete_entries = Entry.where("entry_date < ?", Date.new(2015, 5, 14))
    destroy_entries = @discover.entries
    puts " delete: #{delete_entries.to_sql} "
    puts " destroy #{destroy_entries.to_sql}"
    puts "entry_date: #{@inital_date},  payee: INITIAL BALANCE, amount: #{@inital_balance}, category:{@category_initial_balance.name}"
    if @real_deal
      delete_entries.entries
      destroy_entries.destroy_all
      @discover.entries.create(entry_date: @initial_date, payee: "INITIAL BALANCE",
        amount: @initial_balance, category: @category_initial_balance, memo: "ETL SPECIFIED INIT BALANCE")
    end

  end
  def run_import
    cleanup_before_import

    rows = Disentry.order(post_date: :asc)
    rows.each do |row|
        @balance += row.amount
        category = map_to_app_category(row.description, row.category,row.amount)
        if !category.nil?
          puts "#{row.post_date}\t#{row.description.ljust(40).slice(0..39)}\t #{row.category.ljust(20)}\t#{category.name.ljust(25).slice(0..24)}\t #{row.amount}\t #{row.id}"
          if @real_deal
            @discover.entries.create(entry_date: row.post_date, payee: row.description,
              amount: row.amount, category:category, disentry_id: row.id, memo: "ETL from statements")
          end
        else
          payee = "Transfer : DCU CHECKING"
          puts "#{row.post_date}\t#{payee.ljust(40).slice(0..39)}\t +#{row.category.ljust(20)}\t#{@dcu_checking.name.ljust(25).slice(0..24)}\t #{row.amount} #{row.id}"
          if @real_deal
            @discover.entries.create(entry_date: row.post_date, payee: payee,
              amount: row.amount, transfer_account: @dcu_checking, disentry_id: row.id)
          end
        end
    end
    puts "number of entries: #{rows.count} expected_balance: #{@expected_balance} ",
         "balance: #{@balance} balance_rails: #{@discover.balance} "

  end



end
if __FILE__ == $0
  etl = LoadDisentriesIntoEntries.new(real_deal: true)
  etl.run_import
end
