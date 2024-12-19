class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
    authorize @artists
  end

  def new
    @artist = Artist.new
    @artist.musics.build
  end

  def show
  end

  def create
    @artist = Artist.new(artist_params)
    if @artist.save!
      redirect_to artists_path, notice: "Artist was successfully created."
    else
      # If save fails, render the 'new' page again to show errors
      render :new
    end
  end

  def update
  end

  def destroy
  end

  private

  def artist_params
    params.require(:artist).permit(:date_of_birth, :gender, :full_name,
                                   :address, :first_released_year,
                                   musics_attributes: [:id, :genre, :album_name, :title, :_destroy])
  end
end
