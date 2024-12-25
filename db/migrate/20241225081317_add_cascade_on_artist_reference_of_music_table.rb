class AddCascadeOnArtistReferenceOfMusicTable < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :musics, :artists

    # Add the new foreign key with ON DELETE CASCADE
    add_foreign_key :musics, :artists, on_delete: :cascade
  end
end
