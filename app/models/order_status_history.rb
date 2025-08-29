class OrderStatusHistory < ApplicationRecord
  # Enums
  enum status: {
    pending: 0,
    processing: 1,
    confirmed: 2,
    delivered: 3,
    cancelled: 4
  }, _prefix: true

  # Associations
  belongs_to :order, class_name: Order.name
  belongs_to :admin_user, class_name: User.name, optional: true

  # Validations
  validates :status, presence: true
  validates :changed_at, presence: true

  # Scopes
  scope :recent, -> {order(changed_at: :desc)}
  scope :by_status, ->(status) {where(status:) if status.present?}

  def status_display
    I18n.t("models.order.statuses.#{status}")
  end
end
