class Admin::UsersController < Admin::BaseController
  USERS_INDEX_PRELOAD = %i(orders avatar_attachment).freeze
  DEFAULT_PER_PAGE = 20

  before_action :load_user, only: %i(show toggle_status)
  before_action :check_can_modify_user, only: [:toggle_status]
  before_action :set_filter_options, only: [:index]

  # GET /admin/users
  def index
    filtered_scope = filtered_users.includes(USERS_INDEX_PRELOAD)
    @pagy, @users = pagy(filtered_scope,
                         items: params[:per_page] || DEFAULT_PER_PAGE)

    @total_users = User.count
    @active_users = User.active.count
    @inactive_users = User.inactive.count
    @admin_users = User.admin.count
  end

  # GET /admin/users/:id
  def show
    @recent_orders = @user.recent_orders(10)
    @total_spent = @user.total_spent
    @last_order = @user.last_order
    @orders_count = @user.orders.count
  end

  # PATCH /admin/users/:id/toggle_status
  def toggle_status
    log_toggle_attempt

    reason = extract_reason_from_params
    Rails.logger.info "Reason: #{reason}"

    toggle_user_status(reason)
    Rails.logger.info "Status toggled successfully"

    redirect_with_success_message
  rescue StandardError => e
    handle_toggle_error(e)
  end

  # PATCH /admin/users/bulk_update
  def bulk_update
    user_ids, action_type, reason = extract_bulk_params
    return redirect_no_users_selected if user_ids.blank?

    modifiable_users = find_modifiable_users(user_ids)
    return redirect_no_modifiable_users if modifiable_users.empty?

    begin
      success_count = perform_bulk_action(modifiable_users, action_type, reason)
      redirect_with_bulk_result(success_count, action_type)
    rescue StandardError => e
      Rails.logger.error "Bulk action failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_back(fallback_location: admin_users_path,
                    alert: t("admin.users.bulk_actions.error"))
    end
  end

  private

  def filtered_users
    apply_filters_to_users.sorted_by(params[:sort])
  end

  def apply_filters_to_users
    scope = apply_basic_filters(User.all)
    apply_date_range_if_present(scope)
  end

  def apply_basic_filters scope
    scope = scope.search_by_query(params[:search]) if params[:search].present?
    scope = scope.by_status(params[:status]) if params[:status].present?
    scope = scope.by_role(params[:role]) if params[:role].present?
    scope
  end

  def load_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: t("admin.users.not_found")
  end

  def check_can_modify_user
    return if @user.can_be_deactivated_by?(current_user)

    redirect_to admin_users_path,
                alert: t("admin.users.cannot_modify")
  end

  # Helper methods for toggle_status
  def extract_reason_from_params
    params[:reason] if params[:action_type] == "deactivate"
  end

  def toggle_user_status reason
    if @user.activated?
      @user.deactivate!(reason, current_user)
    else
      @user.activate!(current_user)
    end
    true # Return true if no exception was raised
  end

  def redirect_with_success_message
    status_text = if @user.activated?
                    t("admin.status.active")
                  else
                    t("admin.status.inactive")
                  end
    redirect_back(
      fallback_location: admin_users_path,
      notice: t("admin.users.toggle_status.success",
                user: @user.display_name, status: status_text)
    )
  end

  def redirect_with_error_message error_message = nil
    alert_message = if error_message.present?
                      t("admin.users.toggle_status.error_with_details",
                        error: error_message)
                    else
                      t("admin.users.toggle_status.error")
                    end

    redirect_back(
      fallback_location: admin_users_path,
      alert: alert_message
    )
  end

  # Helper methods for bulk_update
  def extract_bulk_params
    user_ids = params[:user_ids]&.reject(&:blank?)
    action_type = params[:action_type]
    reason = params[:reason] if action_type == "deactivate"
    [user_ids, action_type, reason]
  end

  def find_modifiable_users user_ids
    users = User.where(id: user_ids)
    users.select {|user| user.can_be_deactivated_by?(current_user)}
  end

  def redirect_no_users_selected
    redirect_back(fallback_location: admin_users_path,
                  alert: t("admin.users.bulk_actions.no_users_selected"))
  end

  def redirect_no_modifiable_users
    redirect_back(fallback_location: admin_users_path,
                  alert: t("admin.users.bulk_actions.no_modifiable_users"))
  end

  def perform_bulk_action modifiable_users, action_type, reason
    success_count = 0
    User.transaction do
      modifiable_users.each do |user|
        case action_type
        when "activate"
          success_count += 1 if user.activate!(current_user)
        when "deactivate"
          success_count += 1 if user.deactivate!(reason, current_user)
        end
      end
    end
    success_count
  end

  def redirect_with_bulk_result success_count, action_type
    if success_count.positive?
      action_text = if action_type == "activate"
                      t("admin.status.activated")
                    else
                      t("admin.status.deactivated")
                    end
      redirect_back(fallback_location: admin_users_path,
                    notice: t("admin.users.bulk_actions.success",
                              count: success_count, action: action_text))
    else
      redirect_back(fallback_location: admin_users_path,
                    alert: t("admin.users.bulk_actions.error"))
    end
  end

  def parse_date date_string
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue StandardError
    nil
  end

  def set_filter_options
    @status_options = helpers.status_filter_options
    @role_options = helpers.role_filter_options
    @sort_options = helpers.sort_filter_options
    @bulk_action_options = helpers.bulk_action_options
  end

  def log_toggle_attempt
    Rails.logger.info "Toggle status called for user #{@user.id} " \
                      "by admin #{current_user.id}"
  end

  def handle_toggle_error error
    Rails.logger.error "Failed to toggle user status: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
    redirect_with_error_message(error.message)
  end

  def apply_date_range_if_present scope
    return scope unless params[:start_date].present? &&
                        params[:end_date].present?

    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])

    return scope unless start_date && end_date

    scope.registered_between(start_date, end_date)
  end
end
