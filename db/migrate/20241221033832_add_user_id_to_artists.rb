class AddUserIdToArtists < ActiveRecord::Migration[7.1]
  def change
    add_reference :artists, :user, null: true, foreign_key: true
  end
end
