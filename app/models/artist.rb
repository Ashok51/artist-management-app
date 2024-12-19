# frozen_string_literal: true

class Artist < ApplicationRecord
  validates :first_name, :last_name,
            :date_of_birth, :gender,
            :address, presence: true

  validates :first_released_year, :number_of_albums_released,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0 }, allow_nil: true
end
