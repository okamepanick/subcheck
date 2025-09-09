class ChangePaymentMethodToIntegerInSubscriptions < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TABLE subscriptions
      ALTER COLUMN payment_method TYPE integer
      USING payment_method::integer
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE subscriptions
      ALTER COLUMN payment_method TYPE varchar
      USING payment_method::varchar
    SQL
  end
end
