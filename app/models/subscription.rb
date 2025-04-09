class Subscription < ApplicationRecord
  belongs_to :user

  enum billing_cycle: { monthly: 1, yearly: 2 }

  validates :service_name, presence: true, length: { maximum: 255 }
  validates :start_date, presence: true
  validates :next_billing_date, presence: true
  validate :next_billing_date_after_start_date
  validates :billing_cycle, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, presence: true, length: { maximum: 255 }

  def formatted_start_date
    start_date.strftime("%Y年%m月%d日")
  end

  def formatted_next_billing_date
    next_billing_date.strftime("%Y年%m月%d日")
  end

  def billing_cycle_text
    case billing_cycle
    when "monthly"
      "1ヶ月"
    when "yearly"
      "1年"
    end
  end

  private

  def next_billing_date_after_start_date
    if next_billing_date.present? && next_billing_date <= start_date
      errors.add(:next_billing_date, "開始日より後である必要があります")
    end
  end
end
