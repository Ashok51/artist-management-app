class Music < ApplicationRecord
  belongs_to :artist

  enum genre: { pop: 0, country: 1, classic: 2, rock: 3, jazz: 4 }, _prefix: :genre

  validates :title, :album_name, :genre, presence: true
end
