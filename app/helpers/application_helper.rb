module ApplicationHelper
  include Pagy::Frontend

  def full_title page_title = ""
    base_title = Settings.app.name
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def link_to_locale locale_key
    locale_name = locale_key.to_s.upcase
    current_locale = I18n.locale.to_s
    css_class = current_locale == locale_key.to_s ? "active" : ""

    link_to locale_name, url_for(locale: locale_key), class: css_class
  end

  def alert_class_for message_type
    case message_type.to_s.to_sym
    when :success
      Settings.alert.success
    when :error
      Settings.alert.error
    when :danger
      Settings.alert.danger
    when :warning
      Settings.alert.warning
    when :info
      Settings.alert.info
    else
      "alert-#{message_type}"
    end
  end

  def category_options_for_select root_categories
    options = []

    root_categories.each do |root_category|
      # Add parent category
      options << [root_category.name, root_category.id]

      # Add child categories with  indent
      root_category.children.ordered.each do |child_category|
        options << ["  ├─ #{child_category.name}", child_category.id]
      end
    end

    options
  end

  def sort_options_for_select
    [
      [t("products.index.sort_options.newest"), :newest],
      [t("products.index.sort_options.oldest"), :oldest],
      [t("products.index.sort_options.name_asc"), :name_asc],
      [t("products.index.sort_options.name_desc"), :name_desc],
      [t("products.index.sort_options.price_asc"), :price_asc],
      [t("products.index.sort_options.price_desc"), :price_desc],
      [t("products.index.sort_options.popular"), :popular],
      [t("products.index.sort_options.best_selling"), :best_selling]
    ]
  end

  # Build breadcrumb path for product categories
  def product_category_breadcrumb product
    return [] unless product.categories.any?

    # Find category which has deepest hierarchy (child category)
    deepest_category = product.categories.includes(:parent).max_by do |category|
      depth = 0
      current = category
      while current.parent
        depth += 1
        current = current.parent
      end
      depth
    end

    # Build path from root to leaf
    build_category_path(deepest_category)
  end

  private

  def build_category_path category
    path = []
    current = category

    # Go back from current category to root
    while current
      path.unshift(current)
      current = current.parent
    end

    path
  end
end
