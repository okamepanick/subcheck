class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :service_name
      t.date :start_date
      t.date :next_billing_date
      t.integer :billing_cycle
      t.decimal :price, precision: 10, scale: 2
      t.string :payment_method
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

