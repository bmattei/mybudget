$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
class ImportDiscover

  def initialize(file)
    if (File.exist?(file))
      @file = file
    else
      raise ArgumentError.new("File #{file} not found")
    end
    @discover =  Account.where(name: "Discover Card").first
    @restaurant = Category.where(name: "Food : Restaurants").first
    @groceries = Category.where(name:"Food : Groceries").first
    @auto_gas = Category.where(name:"Transportation : Gas").first
    @rv_gas = Category.where(name: "RV : gasoline").first
    @auto_maint = Category.where(name: "Transportation : Repairs & Maintenance").first
    @rv_maint = Category.where(name: "RV : Maintenance").first
    @medical = Category.where(name:"Personal : Doctor, Dentist").first
    @rv_supplies = Category.where(name:"RV : Equipment/Supplies").first
    @gifts = Category.where(name:"Personal : Gifts").first
    @misc_expense = Category.where(name:"expense : misc").first
    @rv_supplies = Category.where(name:"RV : Equipment/Supplies").first
    @parking = Category.where(name: "Transportation : Parking").first
    @entertainment = Category.where(name: "Recreation : Entertainment").first
    @hotel = Category.where(name: "RV : Hotel").first
    @cloths = Category.where(name: "Personal : cloths").first
    @charity = Category.where(name: "Charity : Other").first
    @campgrounds = Category.where(name: "RV : Campgrounds").first

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
      end
    end
    if category.nil?
      case payee
      when  /(Shutterfly|Redbubble)/i
        category =  @gifts
      when / ( RV )/i
        category = @rv_maint
      when /Parking/i
        category = @parking
      when /(Walmart|lowe's|CVS\/PHARMACY|amazon|AMZN MKTP|USPS|Walgreens|tractor supply)/i
        category = @rv_supplies
      when /(CTS STORE|HOBBY-LOBBY|nancys candy)/i
        category =  @gifts
      when /(brookgreen gardens|skillshare|Natural Bridge|REDBOX|apple\.com|netflix|ESPN|Museu|Tower Hill|Botanic Gard|NYTIMES)/i
        category =  @entertainment
      when /(sprouts farmers|Kroger)/i
        category = @groceries
      when /(Hospital)/i
         category = @medical
      when /(hotel|Holiday Inn|HOUMD PMS|ATHENA INN|Super 8| INN )/i
         category = @hotel
      when /(KOHL|HIBBETT|shoe)/i
          category = @cloths
      when /(CARINGBRIDGE|WWW.LLS.ORG|SAVE THE CHILDREN)/i
          category = @charity
      when /(campground|rv resort|rv park|camp out|red oaks|SWEET WATER FOREST)/i
          category = @campgrounds
      when /(seafood)/
           category = @restaurants

      end
    end


    if category.nil?
      category = @misc_expense
    end

    return category
  end
  def run_import
    col = {date: 1,
               payee: 2,
               amount: 3,
               category: 4
               }
    rows = CSV.read(@file)
    rows.slice(1..).each do |row|
        entry_date = Date.strptime(row[col[:date]], "%m/%d/%Y")
        payee = row[col[:payee]].gsub("tst*","").gsub("SQ*","").gsub(/#.*$/,"")
        input_category = row[col[:category]]
        amount = -(row[col[:amount]].to_f)
        category = map_to_app_category(payee, input_category,amount)

        puts "#{entry_date} **** #{payee} **** #{input_category} **#{category.name} **** #{amount}"

    end

  end



end
if __FILE__ == $0
  etl = ImportDiscover.new(ARGV[0])
  etl.run_import
end
