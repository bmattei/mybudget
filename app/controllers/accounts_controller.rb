class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /accounts or /accounts.json
  def index
    if params[:column] && ["bank", "name", "number", "has_checking"].include?(params[:column])
     if Account.columns_hash[params[:column]].type == :string
       @accounts = Account.filter_by(filtering_params).order("lower(#{params[:column]}) #{params[:direction]}")
     else
       @accounts = Account.filter_by(filtering_params).order("#{params[:column]} #{params[:direction]}")
     end

    else
      @accounts = Account.filter_by(filtering_params)
    end
  end

  # GET /accounts/1 or /accounts/1.json
  def show
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

  def allowed_filters
      return {name_contains: {column: :name, type: :text, label: :name},
              bank_contains: {column: :bank, type: :text,label: :bank},
              number_contains: {coumn: :number, type: :text, label: :number}}
  end
  helper_method :allowed_filters
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    def filtering_params
       params.slice(*(allowed_filters.keys))
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :number, :bank, :has_checking)
    end
end
