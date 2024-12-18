# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone, :date_of_birth, :gender, :address, presence: true

  # Enum gender
  enum gender: { male: 1, female: 2, other: 3 }

  enum role: { super_admin: 0, artist_manager: 1, artist: 2 }

  def full_name
    "#{first_name} #{last_name}"
  end
end
