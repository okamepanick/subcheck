class ChangePaymentMethodToIntegerInSubscriptions < ActiveRecord::Migration[7.2]
  def up
    change_column :subscriptions, :payment_method, :integer
  end

  def down
    change_column :subscriptions, :payment_method, :string
  end
end
