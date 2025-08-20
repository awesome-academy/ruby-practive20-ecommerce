class Admin::CategoriesController < Admin::BaseController
  CATEGORIES_INDEX_PRELOAD = %i(parent children products).freeze

  before_action :load_category,
                only: %i(show edit update destroy update_position toggle_status)
  before_action :load_parent_options, only: %i(new edit create update)

  def index
    @categories = filtered_categories
                  .includes(CATEGORIES_INDEX_PRELOAD)
                  .where(parent_id: nil)
                  .order(:position, :name)
  end

  def show
    @children = @category.children.order(:position, :name)
    @products = @category.products.active.limit(10)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path,
                  notice: t("admin.categories.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path,
                  notice: t("admin.categories.updated_successfully")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.can_be_deleted?
      @category.destroy
      redirect_to admin_categories_path,
                  notice: t("admin.categories.deleted_successfully")
    else
      redirect_to admin_categories_path,
                  alert: t("admin.categories.cannot_delete")
    end
  end

  def sort
    params[:category].each_with_index do |id, index|
      Category.where(id:).update_all(position: index + 1)
    end

    head :ok
  end

  def update_position
    @category.update!(position: params[:position])
    head :ok
  end

  def toggle_status
    @category.update!(is_active: !@category.is_active)
    status_text = if @category.is_active?
                    t("admin.status.active")
                  else
                    t("admin.status.inactive")
                  end
    redirect_back(
      fallback_location: admin_categories_path,
      notice: t("admin.categories.toggle_status.success", status: status_text)
    )
  end

  private

  def filtered_categories
    Category.all
            .search_by_name(params[:search])
            .by_status(params[:status])
            .by_parent(params[:parent_id])
  end

  def load_category
    @category = Category.find(params[:id])
  end

  def load_parent_options
    excluded_ids = [@category&.id].compact
    @parent_options = Category.where.not(id: excluded_ids)
                              .where(parent_id: nil)
                              .order(:position, :name)
                              .pluck(:name, :id)
  end

  def category_params
    params.require(:category).permit(Category::PERMITTED_PARAMS)
  end
end
