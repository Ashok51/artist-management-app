class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
    authorize @artists
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
