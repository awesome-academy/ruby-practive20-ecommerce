class User < ApplicationRecord
  acts_as_paranoid
  has_secure_password

  # Associations
  has_many :orders, dependent: :destroy, class_name: Order.name
  has_one_attached :avatar

  USER_PERMIT = %i(name email password password_confirmation birthday gender
                   phone_number default_address default_recipient_name
                   default_recipient_phone).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MAX_NAME_LENGTH = 50
  MAX_EMAIL_LENGTH = 255
  MAX_AGE_YEARS = 100
  MIN_PASSWORD_LENGTH = 6

  enum gender: {female: 0, male: 1, other: 2}
  enum role: {user: 0, admin: 1}

  # Scopes
  scope :active, -> {where(activated: true)}
  scope :inactive, -> {where(activated: false)}
  scope :latest_first, -> {order(created_at: :desc)}
  scope :admin, -> {where(role: :admin)}
  scope :customer, -> {where(role: :user)}

  # Search scopes
  scope :search_by_name, lambda {|query|
    where("name LIKE ?", "%#{query}%") if query.present?
  }
  scope :search_by_email, lambda {|query|
    where("email LIKE ?", "%#{query}%") if query.present?
  }
  scope :search_by_query, lambda {|query|
    if query.present?
      search_term = "%#{query.strip}%"
      where("name LIKE ? OR email LIKE ?", search_term, search_term)
    end
  }

  # Filter scopes
  scope :by_status, lambda {|status|
    case status
    when "active" then active
    when "inactive" then inactive
    else all
    end
  }

  scope :by_role, lambda {|role|
    case role
    when "admin" then admin
    when "user" then customer
    else all
    end
  }

  scope :registered_between, lambda {|start_date, end_date|
    if start_date.present? && end_date.present?
      where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
  }

  # Sort scopes
  scope :sorted_by, lambda {|sort_option|
    case sort_option
    when "name_asc" then order(:name)
    when "name_desc" then order(name: :desc)
    when "email_asc" then order(:email)
    when "email_desc" then order(email: :desc)
    when "oldest" then order(:created_at)
    else latest_first # default: newest first
    end
  }
  scope :by_role, ->(role) {where(role:) if role.present?}
  scope :by_status, lambda {|status|
    case status
    when "active" then active
    when "inactive" then inactive
    else all
    end
  }
  scope :registered_between, lambda {|start_date, end_date|
    return unless start_date && end_date

    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  before_save {self.email = email.downcase}

  attr_accessor :remember_token, :session_token, :activation_token, :reset_token

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    # When remember user, update remember_digest with remember_token
    # to validate session
    update_column(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_column(:remember_digest, nil)
    self.remember_token = nil
  end

  def generate_session_token
    self.session_token = User.new_token
    # When logging in, update remember_digest with session_token to
    # validate session
    update_column(:remember_digest, User.digest(session_token))
  end

  def forget_session
    # Clear remember_digest when logging out
    update_column(:remember_digest, nil)
    self.session_token = nil
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # Account activation methods
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Password reset methods
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  validates :name, presence: true,
                   length: {maximum: MAX_NAME_LENGTH}
  validates :email, presence: true,
                    length: {maximum: MAX_EMAIL_LENGTH},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  validates :birthday, presence: true,
                       inclusion:
                       {in: MAX_AGE_YEARS.years.ago.to_date..Date.current}
  validates :gender, presence: true
  validates :password,
            length: {minimum: MIN_PASSWORD_LENGTH}, allow_nil: true

  # User management methods
  def can_be_deactivated_by? admin_user
    return false if admin_user == self # Cannot deactivate self
    # Admin cannot deactivate other admins
    return false if admin? && admin_user.admin?

    true
  end

  def deactivate! reason = nil, admin_user = nil
    unless admin_user&.admin?
      raise StandardError, "Only admin users can deactivate accounts"
    end

    unless can_be_deactivated_by?(admin_user)
      raise StandardError, "This user cannot be deactivated by the " \
                           "current admin"
    end

    update!(activated: false, inactive_reason: reason)
  end

  def activate! admin_user = nil
    unless admin_user&.admin?
      raise StandardError, "Only admin users can activate accounts"
    end

    update!(activated: true, inactive_reason: nil)
  end

  def total_spent
    orders.completed.sum(:total_amount)
  end

  def recent_orders limit = 5
    orders.recent.limit(limit)
  end

  def last_order
    orders.recent.first
  end

  def update_last_login!
    update_column(:last_login_at, Time.current)
  end

  def display_name
    name.presence || email.split("@").first
  end

  def status_text
    activated? ? "Active" : "Inactive"
  end

  def role_text
    role.humanize
  end
end
