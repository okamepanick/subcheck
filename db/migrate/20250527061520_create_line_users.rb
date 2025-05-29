class CreateLineUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :line_users do |t|
      t.string :display_name, null: false
      t.integer :line_uid, null: false
      t.timestamps
    end
  end
end
