class CategoriesController < ApplicationController
  include Pagy::Backend
  before_action :set_category, only: %i[ show edit update destroy ]
  helper_method :display_columns, :allow_edit, :allow_delete, :allow_show
  def display_columns
        return [{model_method: "name", column: "name", label: "name"},
          {model_method: "active", column: "active", label: "active"},
          {model_method: "super", column: "categories_categories.name", label: "super" }]
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



  def index
    @pagy, @categories = pagy(Category.order(active: :desc).order(:name).left_outer_joins(:category).filter_by(filtering_params).order("#{params[:column]} #{params[:direction]}"),
                       items: 10)
    @allow_delete = false
    @allow_edit = false
    # return @categories
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    redirect_url = params[:category][:referrer] || categories_url

    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to redirect_url, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    redirect_url = params[:category][:referrer] || categories_url

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to redirect_url, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to categories_url, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end
    def process_index_params
        return
    end
    def filtering_params
     params.slice(*Category.filter_scopes)
    end
    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:name, :active, :category_id, :level)
    end
end
