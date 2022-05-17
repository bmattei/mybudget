class EntriesController < ApplicationController
  before_action :set_entry, only: %i[ show edit update destroy ]
  # before_action :set_account, only: %i[ show edit update destroy ]

  def display_columns
        return [
                 {model_method: "account_name", column: "accounts.name", label: "Account"},
                 {model_method: "category_or_transfer_account", column: "categories.name", label: "Category/Transfer"},
                 {model_method: "entry_date", column: "entries.entry_date", label: "Entrydate" },
                 {model_method: "check_number", column: "entries.check_number", label: 'check#' },
                 {model_method: "payee", column: "entries.payee", label: "payee" },
                 {model_method: "inflow", column: "entries.amount", label: "inflow", as: :money},
                 {model_method: "outflow", column: "entries.amount", label: "outflow", as: :money},
                 {model_method: "balance", label: "Balance", as: :money}
                ]
  end
  helper_method :display_columns
  # GET /entries or /entries.json
  def index

    @entries = Entry.filter_by(filtering_params).joins(:account).left_outer_joins(:category).order("accounts.name asc").order(entry_date: :asc).order("#{params[:column]} #{params[:direction]}")

  end

  # GET /entries/1 or /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @entry = Entry.new
    @entry.account_id = params[:account_id]
    @entry.entry_date = Date.today
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries or /entries.json
  def create
    @entry = Entry.new(entry_params)
    respond_to do |format|
      if @entry.save
        format.html { redirect_to account_url(@entry.account), notice: "Entry was successfully created." }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to account_url(@entry.account), notice: "Entry was successfully updated." }
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

      params["entry"]["amount"] = params["entry"]["inflow"].to_f > 0 ? params["entry"]["inflow"] : (-(params["entry"]["outflow"].to_f)).to_s
      params[:entry].delete(:outflow)
      params[:entry].delete(:inflow)



      params.require(:entry).permit(:account_id, :entry_date, :check_number, :payee, :amount,
                                                          :transfer_account_id, :transfer_entry_id, :category_id)


    end
end
