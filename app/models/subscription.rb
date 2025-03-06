class Subscription < ApplicationRecord
  belongs_to :user

  enum billing_cycle: { monthly: 1, yearly: 12 }
end

