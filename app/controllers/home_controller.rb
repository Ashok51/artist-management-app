class HomeController < ApplicationController
  def index
    redirect_to new_user_session_path if !user_signed_in?

    if current_user.artist?
      redirect_to musics_path
    elsif current_user.artist_manager?
      redirect_to artists_path
    else
      redirect_to admin_users_path
    end
  end
end
