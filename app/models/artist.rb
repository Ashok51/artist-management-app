# frozen_string_literal: true

class Artist < ApplicationRecord
  validates :full_name,
            :date_of_birth, :gender,
            :address, presence: true

  validates :no_of_albums_released,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0 }, allow_nil: true

  enum gender: { male: 'Male', female: 'Female', other: 'Other' }

  has_many :musics, dependent: :destroy, inverse_of: :artist

  belongs_to :user, optional: true

  accepts_nested_attributes_for :musics, allow_destroy: true, reject_if: :all_blank
end
