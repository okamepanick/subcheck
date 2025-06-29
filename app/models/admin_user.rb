class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :subscriptions

  validates :username, presence: true, length: {minimum:3, maximum:10}

  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  def password_required?
      new_record? || password.present? || password_confirmation.present?
  end
end
