class User < ApplicationRecord
  has_secure_password

  USER_PERMIT = %i(name email password password_confirmation birthday
gender).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MAX_NAME_LENGTH = 50
  MAX_EMAIL_LENGTH = 255
  MAX_AGE_YEARS = 100
  MIN_PASSWORD_LENGTH = 6

  enum gender: {female: 0, male: 1, other: 2}

  before_save {self.email = email.downcase}

  attr_accessor :remember_token, :session_token

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

  def authenticated? token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(token)
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
