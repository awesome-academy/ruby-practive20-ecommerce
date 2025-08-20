class Admin::CategoriesController < Admin::BaseController
  CATEGORIES_INDEX_PRELOAD = %i(parent children products).freeze

  before_action :load_category,
                only: %i(show edit update destroy update_position toggle_status)
  before_action :load_parent_options, only: %i(new edit create update)
  before_action :check_can_be_deleted, only: %i(destroy)

  # GET /admin/categories
  def index
    @categories = filtered_categories
                  .includes(CATEGORIES_INDEX_PRELOAD)
                  .where(parent_id: nil)
                  .order(:position, :name)
  end

  # GET /admin/categories/:id
  def show
    @childrens = @category.children.order(:position, :name)
    @products = @category.products.active.limit(10)
  end

  # GET /admin/categories/new
  def new
    @category = Category.new
  end

  # POST /admin/categories
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path,
                  notice: t("admin.categories.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/categories/:id/edit
  def edit; end

  # PATCH/PUT /admin/categories/:id
  def update
    if @category.update(category_params)
      redirect_to admin_categories_path,
                  notice: t("admin.categories.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/categories/:id
  def destroy
    if @category.destroy
      redirect_to admin_categories_path,
                  notice: t("admin.categories.destroy.success")
    else
      redirect_to admin_categories_path,
                  alert: t("admin.categories.destroy.error")
    end
  end

  # PATCH /admin/categories/sort
  def sort
    params[:category].each_with_index do |id, index|
      Category.where(id:).update_all(position: index + 1)
    end

    head :ok
  end

  # PATCH /admin/categories/:id/update_position
  def update_position
    if @category.update(position: params[:position])
      head :ok
    else
      head :unprocessable_entity
    end
  end

  # PATCH /admin/categories/:id/toggle_status
  def toggle_status
    if @category.update(is_active: !@category.is_active)
      status_text = if @category.is_active?
                      t("admin.status.active")
                    else
                      t("admin.status.inactive")
                    end
      redirect_back(
        fallback_location: admin_categories_path,
        notice: t("admin.categories.toggle_status.success", status: status_text)
      )
    else
      redirect_back(
        fallback_location: admin_categories_path,
        alert: t("admin.categories.toggle_status.error")
      )
    end
  end

  private

  def filtered_categories
    Category.all
            .search_by_name(params[:search])
            .by_status(params[:status])
            .by_parent(params[:parent_id])
  end

  def load_category
    @category = Category.find_by(id: params[:id])
    return if @category

    redirect_to admin_categories_path, alert: t("admin.categories.not_found")
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

  def check_can_be_deleted
    return if @category.can_be_deleted?

    redirect_to admin_categories_path,
                alert: t("admin.categories.cannot_delete")
  end
end
