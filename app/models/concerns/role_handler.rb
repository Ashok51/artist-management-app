module RoleHandler
  extend ActiveSupport::Concern

  included do
    after_create :create_artist_record_if_user_role_is_artist
    before_update :handle_artist_record_on_role_change
  end

  private

  def create_artist_record_if_user_role_is_artist
    return unless artist?

    ArtistService.create_artist(self)
  end

  def handle_artist_record_on_role_change
    return unless role_changed?

    if role == 'artist'
      ArtistService.create_artist(self)
    elsif role_was == 'artist' && role != 'artist'
      ArtistService.delete_artist(id)
    end
  end
end
