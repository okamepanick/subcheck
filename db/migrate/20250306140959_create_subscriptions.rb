class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :service_name, null: false
      t.date :start_date, null: false
      t.date :next_billing_date, null: false
      t.integer :billing_cycle, null: false
      t.integer :price, null: false
      t.string :payment_method, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

