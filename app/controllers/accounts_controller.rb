class AccountsController < ApplicationController
  include Pagy::Backend
  before_action :set_account, only: %i[ show edit update destroy ]
  helper_method :display_columns, :allow_edit, :allow_show, :allow_delete


  # GET /accounts or /accounts.json
  def index
    if !params[:column]
      @pagy ,@accounts = pagy(Account.filter_by(filtering_params).order(bank: :asc, name: :asc),
                              items: 10)
    else
      @pagy ,@accounts = pagy(Account.filter_by(filtering_params).order("#{params[:column]} #{params[:direction]}"),
                              items: 10)
    end


  end

  # GET /accounts/1 or /accounts/1.json
  def show

    @account = Account.find(params[:id])
    @filters = params.slice(*Entry.filter_scopes)
    @filters.permit!
    @pagy, @entries = pagy(@account.entries.filter_by(params.slice(*Entry.filter_scopes)).
    left_outer_joins(:category).
    order("#{params[:column]} #{params[:direction]}").
    normal_order, items: 10)
    @sum = @entries.sum(:amount)
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
        flash[:notice] = "Account was successfully created"
        format.html { render "create"}
        format.json { render :index, status: :created}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    puts "\n++++++++++++++++++++++++++++++++++++++Enter update #{account_params}\n"
    respond_to do |format|
      if @account.update(account_params)
        puts "\n+++++++++++++++++++++UPDATE success "
        format.html { redirect_to accounts_url, notice: "Account was successfully updated." }
        format.json { render :index, status: :ok }
      else      
        puts "\n+++++++++++++++++++++UPDATE ERROR "
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
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end



    # Only allow a list of trusted parameters through.
    def account_params
      puts "+++++++++++++++++++++++++enter account params: #{params}\n"
      params.require(:account).permit(:name, :number, :bank, :has_checking, :in_menu)
    end
end
