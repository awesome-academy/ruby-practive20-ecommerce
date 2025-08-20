class Brand < ApplicationRecord
  PERMITTED_PARAMS = %i(name description is_active position).freeze

  # Relationships
  has_many :products, dependent: :destroy, class_name: Product.name
  has_one_attached :logo

  # Validations
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :slug, presence: true, uniqueness: true, length: {maximum: 255}
  validates :is_active, inclusion: {in: [true, false]}

  # Callbacks
  before_validation :generate_slug
  before_create :set_position

  # Scopes
  scope :active, -> {where(is_active: true)}
  scope :inactive, -> {where(is_active: false)}
  scope :sorted_by_position, -> {order(:position, :name)}
  scope :sorted_by_name, -> {order(:name)}

  # Admin helper methods
  def toggle_status!
    update!(is_active: !is_active)
  end

  def can_be_deleted?
    products.empty?
  end

  delegate :count, to: :products, prefix: true

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def set_position
    self.position = (Brand.maximum(:position) || 0) + 1 if position.blank?
  end
end
