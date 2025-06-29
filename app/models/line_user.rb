class LineUser < ApplicationRecord
  has_many :subscriptions

  validates :line_uid, presence: true, uniqueness: true
end
