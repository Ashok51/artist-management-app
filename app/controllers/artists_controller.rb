# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[show edit update destroy]
  before_action :set_artist_for_export, only: %i[export]

  require 'csv'

  def index
    @artists = Artist.page(params[:page])
    authorize @artists
  end

  def new
    @artist = Artist.new

    authorize @artist

    @artist.musics.build
  end

  def show
    authorize @artist
  end

  def create
    @artist = Artist.new(artist_params)

    authorize @artist

    if @artist.save!
      redirect_to artists_path, notice: 'Artist was successfully created.'
    else
      render :new
    end
  end

  def edit
    authorize @artist
  end

  def update
    authorize @artist

    if @artist.update(artist_params)
      redirect_to artists_path, notice: 'artist was successfully updated.'
    else
      flash.now[:alert] = 'Failed to update the artist.'
      render :edit
    end
  end

  def destroy
    authorize @artist

    if @artist.destroy
      redirect_to artists_path, notice: 'Artist was successfully deleted.'
    else
      redirect_to artists_path, alert: 'Failed to delete an Artist. Please try again.'
    end
  end

  def export
    csv_data = CsvExportService.export_artists_and_musics

    send_data csv_data, filename: "artists_and_musics-#{Date.today}.csv", type: 'text/csv'
  end

  def import
    file = params[:file]
    begin
      CsvImportService.import_artists_and_musics(file)
      redirect_to artists_path, notice: 'Artists and Musics were successfully imported.'
    rescue ArgumentError => e
      redirect_to artists_path, alert: e.message
    rescue StandardError => e
      redirect_to artists_path, alert: "An error occurred: #{e.message}"
    end
  end

  private

  def artist_params
    params.require(:artist).permit(:date_of_birth, :gender, :full_name,
                                   :address, :first_released_year,
                                   musics_attributes: %i[id genre album_name title _destroy])
  end

  def set_artist
    @artist = Artist.find(params[:id])
  end

  def set_artist_for_export
    @artists = Artist.includes(:musics).all
  end
end
