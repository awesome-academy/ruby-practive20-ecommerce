class StaticPagesController < ApplicationController
  FEATURED_PRODUCTS_PRELOAD = %i(brand categories).freeze

  # GET /
  def home
    @featured_products = Product.active.featured
                                .includes(FEATURED_PRODUCTS_PRELOAD)
                                .limit(Settings
                                .business.featured_products_limit)
  end

  # GET /help
  def help; end

  # GET /about
  def about; end

  # GET /contact
  def contact; end
end
