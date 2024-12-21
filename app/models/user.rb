# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone, :date_of_birth, :gender, :address, presence: true

  enum gender: { male: 1, female: 2, other: 3 }
  enum role: { super_admin: 0, artist_manager: 1, artist: 2 }

  has_one :artist, dependent: :destroy

  after_create :create_artist_record_if_needed

  before_update :handle_artist_record_on_role_change

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  # artist record is created during creation of user first as default user role is "artist"
  # artist record is created during update of user from super_admin and artist_manager to "artist"
  def create_artist_record_if_needed
    return unless artist?

    create_artist!(
      full_name: full_name,
      date_of_birth: date_of_birth,
      gender: gender,
      address: address
    )
  end

  def handle_artist_record_on_role_change
    return unless role_changed?

    if role == 'artist'
      create_artist_record_if_needed
    elsif role_was == 'artist' && role != 'artist'
      artist&.destroy
    end
  end
end
