# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[show edit update destroy]
  before_action :set_artist_for_export, only: %i[export]
  before_action :set_page_number, only: %i[index]

  require 'csv'
  require_relative './concerns/sql_queries'
  include DatabaseExecution

  def index
    per_page = 5
    @total_pages = total_page_of_artist_table(per_page)
    @artists = paginate_artists(per_page)

    policy_scope(Artist)
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

    authorize :artist, :export?

    send_data csv_data, filename: "artists_and_musics-#{Date.today}.csv", type: 'text/csv'
  end

  def import
    file = params[:file]

    authorize :artist, :import?

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

  def total_page_of_artist_table(per_page)
    query = SQLQueries::COUNT_ARTISTS

    total_count = execute_sql(query).first['count'].to_i

    (total_count.to_f / per_page).ceil
  end

  def paginate_artists(per_page)
    query = SQLQueries::ORDER_ARTIST_RECORD
    result = Pagination.paginate(query, @page_number, per_page)
    Artist.build_artist_object_from_json(result)
  end

  def set_page_number
    @page_number = params[:page].to_i || 1
  end
end
