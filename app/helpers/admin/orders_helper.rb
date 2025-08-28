module Admin::OrdersHelper
  def order_status_badge_class status
    case status.to_s
    when "pending_confirmation"
      "bg-warning text-dark"
    when "confirmed"
      "bg-info"
    when "processing"
      "bg-primary"
    when "shipping"
      "bg-secondary"
    when "completed"
      "bg-success"
    when "cancelled"
      "bg-danger"
    else
      "bg-light text-dark"
    end
  end

  def history_status_color status
    case status.to_s
    when "pending_confirmation"
      "bg-warning"
    when "confirmed"
      "bg-info"
    when "processing"
      "bg-primary"
    when "shipping"
      "bg-secondary"
    when "completed"
      "bg-success"
    when "cancelled"
      "bg-danger"
    else
      "bg-light"
    end
  end

  def history_status_icon status
    case status.to_s
    when "pending_confirmation"
      "fa-clock"
    when "confirmed"
      "fa-check"
    when "processing"
      "fa-cog"
    when "shipping"
      "fa-truck"
    when "completed"
      "fa-check-circle"
    when "cancelled"
      "fa-times"
    else
      "fa-question"
    end
  end

  def order_status_options_for_select
    Order.statuses.keys.map do |status|
      [t("orders.status.#{status}"), status]
    end
  end

  def payment_method_options_for_select
    Order.payment_methods.keys.map do |method|
      [t("orders.payment_method.#{method}"), method]
    end
  end

  def can_update_order_status? order, new_status
    case order.status.to_sym
    when :pending_confirmation
      %w(confirmed cancelled).include?(new_status)
    when :confirmed
      %w(processing cancelled).include?(new_status)
    when :processing
      %w(shipping cancelled).include?(new_status)
    when :shipping
      %w(completed).include?(new_status)
    else
      false
    end
  end
end
