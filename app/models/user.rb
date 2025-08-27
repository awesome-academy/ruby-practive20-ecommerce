class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :orders, dependent: :destroy, class_name: Order.name

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
  scope :latest_first, -> {order(created_at: :desc)}
  scope :admin, -> {where(role: :admin)}
  scope :customer, -> {where(role: :customer)}

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
end
