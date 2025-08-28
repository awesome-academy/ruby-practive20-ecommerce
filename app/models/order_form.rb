class OrderForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  # Constants
  PHONE_CLEANUP_PATTERN = Regexp.new(Settings
                                     .validation.phone.cleanup_pattern).freeze
  VIETNAM_PHONE_PATTERN = Regexp.new(Settings
                                     .validation.phone.vietnam_pattern).freeze

  # Form attributes
  attribute :recipient_name, :string
  attribute :recipient_phone, :string
  attribute :delivery_address, :string
  attribute :note, :string
  attribute :payment_method, :string, default: "cod"
  attribute :shipping_method, :string, default: "standard"
  attribute :terms_accepted, :boolean, default: false

  # Validations
  validates :recipient_name, presence: true, length: {maximum: 255}
  validates :recipient_phone, presence: true
  validates :delivery_address, presence: true, length: {maximum: 500}
  validates :payment_method, presence: true,
            inclusion: {in: %w(cod bank_transfer ewallet)}
  validates :shipping_method, presence: true,
            inclusion: {in: %w(standard express same_day)}
  validates :terms_accepted, acceptance: {
    message: I18n.t("errors.messages.must_accept_terms")
  }

  validates :note, length: {maximum: 1000}, allow_blank: true

  # Additional custom validations
  validate :validate_phone_format

  private

  def validate_phone_format
    return if recipient_phone.blank?

    # Clean phone number
    cleaned_phone = recipient_phone.gsub(PHONE_CLEANUP_PATTERN, "")

    # Vietnamese phone number validation
    return if cleaned_phone.match?(VIETNAM_PHONE_PATTERN)

    errors.add(:recipient_phone, I18n.t("errors.messages.invalid_phone"))
  end
end
