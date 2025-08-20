class Admin::DashboardController < Admin::BaseController
  RECENT_PRODUCTS_PRELOAD = %i(brand categories).freeze

  def index # rubocop:disable Metrics/AbcSize
    @stats = {
      total_products: Product.count,
      active_products: Product.active.count,
      featured_products: Product.featured.count,
      low_stock_products: Product.low_stock.count,
      total_categories: Category.count,
      active_categories: Category.active.count,
      total_users: User.count,
      admin_users: User.admin.count
    }

    @recent_products = Product.includes(RECENT_PRODUCTS_PRELOAD)
                              .order(created_at: :desc).limit(5)
    @low_stock_products = Product.low_stock.limit(5)
    @recent_categories = Category.includes(:products).order(:name)
                                 .limit(Settings
                                        .admin.dashboard_categories_limit)
  end
end
