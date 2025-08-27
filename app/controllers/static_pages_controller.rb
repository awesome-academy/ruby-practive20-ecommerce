class StaticPagesController < ApplicationController
  FEATURED_PRODUCTS_PRELOAD = %i(brand categories).freeze

  def home
    @featured_products = Product.active.featured
                                .includes(FEATURED_PRODUCTS_PRELOAD)
                                .limit(Settings
                                .business.featured_products_limit)
  end

  def help; end

  def about; end

  def contact; end
end
