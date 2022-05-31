class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show edit update destroy ]
  helper_method :display_columns, :allow_edit, :allow_show, :allow_delete
  def display_columns
        return [{model_method: "bank", column: "bank", label: "bank"},
                {model_method: "name", column: "name", label: "name" },
                {model_method: "number", column: "number", label: "Number"},
                {model_method: "has_checking", column: "has_checking", label: "Checking"}]
  end

  def allow_edit
      true
  end
  def allow_show
      true
  end
  def allow_delete
      true
  end


  private def filtering_params
    params.slice(*Account.filter_scopes)
  end

  # GET /accounts or /accounts.json
  def index
       @accounts = Account.filter_by(filtering_params).order("#{params[:column]} #{params[:direction]}")
  end

  # GET /accounts/1 or /accounts/1.json
  def show
    @account = Account.find(params[:id])
    filters = params.slice(*Entry.filter_scopes)
    params[:date_after] = Date.today - 6.months if filters.keys.count == 0
    @entries = @account.entries.filter_by(params.slice(*Entry.filter_scopes)).
    left_outer_joins(:category).
    order("#{params[:column]} #{params[:direction]}").
    order(entry_date: :desc).order(amount: :desc)


  end


  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts or /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to accounts_url, notice: "Account was successfully created." }
        format.json { render :index, status: :created}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to accounts_url, notice: "Account was successfully updated." }
        format.json { render :index, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url, notice: "Account was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end



    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :number, :bank, :has_checking, :in_menu)
    end
end
