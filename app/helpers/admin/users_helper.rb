module Admin::UsersHelper
  def order_status_class status
    case status.to_s
    when "pending"
      "warning"
    when "confirmed", "processing"
      "info"
    when "shipped"
      "primary"
    when "delivered"
      "success"
    when "cancelled", "refunded"
      "danger"
    else
      "default"
    end
  end

  def user_avatar user, size: 40
    if user.avatar.attached?
      image_tag user.avatar, class: "img-circle", size: "#{size}x#{size}"
    else
      content_tag :div, user.display_name.first.upcase,
                  class: "avatar-placeholder",
                  style: "width: #{size}px; height: #{size}px; " \
                         "font-size: #{size / 2.5}px;"
    end
  end

  def user_status_badge user
    if user.activated?
      content_tag :span, t("admin.status.active"), class: "label label-success"
    else
      content_tag :span, t("admin.status.inactive"), class: "label label-danger"
    end
  end

  def user_role_badge user
    css_class = user.admin? ? "label label-info" : "label label-default"
    content_tag :span, user.role_text, class: css_class
  end

  def format_currency amount
    number_to_currency(amount, unit: "₫", precision: 0, delimiter: ",")
  end

  # Filter options helpers
  def status_filter_options
    [
      [t("admin.users.filter.all_status"), ""],
      [t("admin.users.filter.active"), "active"],
      [t("admin.users.filter.inactive"), "inactive"]
    ]
  end

  def role_filter_options
    [
      [t("admin.users.filter.all_roles"), ""],
      [t("admin.users.filter.admin"), "admin"],
      [t("admin.users.filter.user"), "user"]
    ]
  end

  def sort_filter_options
    [
      [t("admin.users.sort.newest_first"), ""],
      [t("admin.users.sort.oldest_first"), "oldest"],
      [t("admin.users.sort.name_asc"), "name_asc"],
      [t("admin.users.sort.name_desc"), "name_desc"],
      [t("admin.users.sort.email_asc"), "email_asc"],
      [t("admin.users.sort.email_desc"), "email_desc"]
    ]
  end

  def bulk_action_options
    [
      [t("admin.users.bulk_actions.select_action"), ""],
      [t("admin.users.bulk_actions.activate"), "activate"],
      [t("admin.users.bulk_actions.deactivate"), "deactivate"]
    ]
  end

  def format_last_login user
    if user.last_login_at.present?
      "#{time_ago_in_words(user.last_login_at)} ago"
    else
      t("admin.users.never_logged_in")
    end
  end
end
