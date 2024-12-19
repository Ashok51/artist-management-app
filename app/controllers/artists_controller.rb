class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
    authorize @artists
  end

  def new
    @artist = Artist.new
  end

  def show
  end

  def create
  end

  def update
  end

  def destroy
  end
end
