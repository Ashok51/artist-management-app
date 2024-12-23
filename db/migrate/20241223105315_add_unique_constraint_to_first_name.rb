class AddUniqueConstraintToFirstName < ActiveRecord::Migration[7.1]
  def change
    add_index :artists, :full_name, unique: true
  end
end
