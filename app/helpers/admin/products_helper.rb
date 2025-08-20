module Admin::ProductsHelper
  def admin_product_status_options
    [
      [t("admin.products.index.filters.all_statuses"), ""],
      [t("admin.products.index.filters.active"), :active],
      [t("admin.products.index.filters.inactive"), :inactive]
    ]
  end

  def admin_product_stock_status_options
    [
      [t("admin.products.index.filters.all_stock_levels"), ""],
      [t("admin.products.index.filters.in_stock"), :in_stock],
      [t("admin.products.index.filters.low_stock"), :low_stock],
      [t("admin.products.index.filters.out_of_stock"), :out_of_stock]
    ]
  end

  def admin_product_featured_options
    [
      [t("admin.products.index.filters.all_products"), ""],
      [t("admin.products.index.filters.featured"), :featured],
      [t("admin.products.index.filters.not_featured"), :not_featured]
    ]
  end

  def admin_product_sort_options
    [
      [t("admin.products.index.sort.created_desc"), :created_desc],
      [t("admin.products.index.sort.created_asc"), :created_asc],
      [t("admin.products.index.sort.name_asc"), :name_asc],
      [t("admin.products.index.sort.name_desc"), :name_desc],
      [t("admin.products.index.sort.price_asc"), :price_asc],
      [t("admin.products.index.sort.price_desc"), :price_desc],
      [t("admin.products.index.sort.stock_asc"), :stock_asc],
      [t("admin.products.index.sort.stock_desc"), :stock_desc]
    ]
  end
end
