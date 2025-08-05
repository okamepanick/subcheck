class Subscription < ApplicationRecord
  belongs_to :line_user

  enum billing_cycle: { monthly: 1, yearly: 2 }
  enum payment_method: { credit_card: 1, bank_transfer: 2, direct_debit: 3 }

  validates :service_name, presence: true, length: { maximum: 255 }
  validates :start_date, presence: true
  validates :next_billing_date, presence: true
  validates :billing_cycle, presence: true
  validate :next_billing_date_after_start_date
  validates :price, presence: true
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

  # 次回請求日が過ぎていれば更新する
  def update_billing_date_if_overdue
    return unless next_billing_date < Date.today

    new_date = case billing_cycle
    when "monthly"
      next_billing_date.next_month
    when "yearly"
      next_billing_date.next_year
    end

    update(next_billing_date: new_date)
  end

  private

  def next_billing_date_after_start_date
    if next_billing_date.present? && next_billing_date <= start_date
      errors.add(:next_billing_date, "開始日より後である必要があります")
    end
  end
end
