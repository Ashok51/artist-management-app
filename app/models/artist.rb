# frozen_string_literal: true

class Artist < ApplicationRecord

  validates :full_name,
            :date_of_birth, :gender,
            :address, presence: true

  validates :first_released_year, :no_of_albums_released,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0 }, allow_nil: true

  has_many :musics
end
