# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
line_user1 = LineUser.find_or_create_by!(line_uid: "1234") do |user|
  user.display_name = "test"
end

line_user1.subscriptions.find_or_create_by!(
  service_name: "アマゾン",
  start_date: Date.new(2025, 6, 1),
  next_billing_date: Date.new(2025, 6, 30),
  billing_cycle: 1,
  price: 4000,
  payment_method: "現金"
)