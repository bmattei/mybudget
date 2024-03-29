class EntriesController < ApplicationController
  include Pagy::Backend

  before_action :set_entry, only: %i[ show edit update destroy ]
  helper_method :display_columns, :allow_edit, :allow_delete, :allow_show

  # before_action :set_account, only: %i[ show edit update destroy ]

  def display_columns(for_account = false)
        # as is used to manipulate how data is displayed the method is defined in
        # application_helper and used bfoy the views
        all_columns =  [
                 {model_method: "account_name", column: "accounts.name", label: "Account"},
                 {model_method: "cleared", colomn: "account.cleared", label:"Cleared"},
                 {model_method: "category_name", column: "categories.name", label: "Category"},
                 {model_method: "entry_date", column: "entries.entry_date", label: "Entrydate", as: :date},
                 {model_method: "check_number", column: "entries.check_number", label: 'check#' },
                 {model_method: "payee", column: "entries.payee", label: "payee" },
                 {model_method: "memo", column: "entries.memo", label: "memo" },
                 {model_method: "inflow", column: "entries.amount", label: "inflow", as: :money},
                 {model_method: "outflow", column: "entries.amount", label: "outflow", as: :money},
                 {model_method: "balance", column: "entries.balance", label: "Balance", as: :money}
                ]
        return for_account ? all_columns.slice(1..) : all_columns
  end
  def allow_edit
      true
  end
  def allow_show
      false
  end
  def allow_delete
      true
  end


  # GET /entries or /entries.json
  def index

    @pagy, @entries = pagy(Entry.filter_by(params.slice(*Entry.filter_scopes)).
    left_outer_joins(:category).
    order("#{params[:column]} #{params[:direction]}").
    normal_order, items: 10)

  end

  def allowed_types
    ["column_chart", "pie_chart", "line_chart"]
  end
  helper_method :allowed_types
  def allowed_intervals
    ["", "year", "quarter", "month"]
  end
  helper_method :allowed_intervals



  def reporting
    @type = allowed_types.include?(params["type"]) ?  params["type"] : "column_chart"
    interval = allowed_intervals.include?(params["interval"]) ?  params["interval"] : ""
    @report_data = Entry.joins(:category).joins(category: :category)
    if (params[:start] && params[:start].to_date.is_a?(Date))
      @report_data = @report_data.where("entry_date >= ?", params[:start])
    end
    if (params[:end] && params[:end].to_date.is_a?(Date))
      @report_data = @report_data.where("entry_date <= ?", params[:end])
    end
    category_str = "categories_categories.name"

    if params[:category_id] && params[:category_id].length > 0
      @report_data = @report_data.where("categories.category_id = ?", params[:category_id])
      category_str = "categories.name"
    end

   loan_id = Category.where(name: "LOANS").first
   income_id = Category.where(name: "INCOME").first
   @categories = Category.where(category_id: params[:category_id].to_i > 0 ? params[:category_id].to_i : nil).
                    where.not(id: loan_id).where.not(id:income_id).order(name: :asc)
    if interval.length > 0
      @report_data = @report_data.group("date_trunc(\'#{interval}\', entry_date)").group(category_str).sum(:amount)
      @report_data.delete_if {|k,v| v > 0}
      @report_data.each {|k,v| @report_data[k] = v.abs}
      if interval.eql?("year")
        @report_data.each {|k,v| k[0] = k[0].to_date.year}
      else
        @report_data.each {|k,v| k[0] = k[0].to_date}
      end
      @report_data = multi_chart_data(@report_data).sort{|a,b| b <=> a }.to_h
    else
      @report_data = @report_data.group(category_str).sum(:amount)
      @report_data.delete_if {|k,v| v > 0}
      @report_data.each {|k,v| @report_data[k] = v.abs}
    end

  end

  # GET /entries/1 or /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @referrer = request.referrer
    @entry = Entry.new
    @entry.account_id = params[:account_id]
    @entry.entry_date = session[:last_date] ?  session[:last_date].to_date : Date.today
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries or /entries.json
  def create
    session[:last_date] = entry_params[:entry_date]
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        flash[:notice] = "Entry was successfully created"
        format.html { render "create"}
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    redirect_url = params[:entry][:referrer] || account_url(@entry.account)
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to redirect_url, notice: "Entry was successfully updated." }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1 or /entries/1.json
  def destroy
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to entries_url, notice: "Entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # This takes a hash where the keys arrays of two entries and breaks it into
    # a hash of hashes so {[1,4] => a, [2,4] = b} becomes {1=> {4=>a}, 2=> {4=>b}}
    # This allows us to create seperated charts for each date when using group_by date

    def multi_chart_data(data)
      return_hash = {}
      data.each do |key, value|
        return_hash[key[0]] ||= {}
        return_hash[key[0]][key[1]] ||= value
      end
      return_hash
    end
    def filtering_params
      params.slice(*Entry.filter_scopes)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    def set_account
     @account = Account.find(params[:account_id])
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      set_amount
      params.require(:entry).permit(:account_id, :entry_date, :check_number, :payee, :amount, :memo,
                                                          :transfer_account_id,  :category_id)
    end

    private def set_amount
      params[:amount] = nil
      if params["entry"]["inflow"] && params["entry"]["inflow"].to_f > 0.0
        params[:entry][:amount] = params["entry"]["inflow"]
      elsif params["entry"]["outflow"] && params["entry"]["outflow"].to_f > 0.0
        params[:entry][:amount] = (-params["entry"]["outflow"].to_f).to_s
      end
      params[:entry].delete(:outflow)
      params[:entry].delete(:inflow)
    end
end
