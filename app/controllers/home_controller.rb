class HomeController < ApplicationController
  def index
    if current_user.artist?
      redirect_to musics_path
    elsif current_user.artist_manager?
      redirect_to artists_path
    else
      redirect_to admin_users_path
    end
  end
end
