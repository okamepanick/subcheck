class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :subscriptions

  validates :username, presence: true, length: {minimum:3, maximum:10}

  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :line_user_id, presence: true, uniqueness: true

  def password_required?
      new_record? || password.present? || password_confirmation.present?
  end
end
