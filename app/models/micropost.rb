class Micropost < ApplicationRecord
  scope :latest_first, -> {order(created_at: :desc)}
end
