class User < ApplicationRecord
  include RoleHandler

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone, :date_of_birth, :gender, :address, presence: true

  enum gender: { male: 1, female: 2, other: 3 }
  enum role: { super_admin: 0, artist_manager: 1, artist: 2 }

  has_one :artist, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.build_user_object_from_json(result)
    result.map { |user| new(user) }
  end
end
