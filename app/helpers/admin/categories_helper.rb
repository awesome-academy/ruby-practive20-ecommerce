module Admin::CategoriesHelper
  def admin_category_status_options
    [
      [t("admin.categories.index.filters.all_statuses"), ""],
      [t("admin.categories.index.filters.active"), :active],
      [t("admin.categories.index.filters.inactive"), :inactive]
    ]
  end

  def admin_category_sort_options
    [
      [t("admin.categories.index.sort.position"), :position],
      [t("admin.categories.index.sort.name_asc"), :name_asc],
      [t("admin.categories.index.sort.name_desc"), :name_desc],
      [t("admin.categories.index.sort.created_desc"), :created_desc],
      [t("admin.categories.index.sort.created_asc"), :created_asc]
    ]
  end
end
