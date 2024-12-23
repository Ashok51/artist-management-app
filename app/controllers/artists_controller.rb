# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[show edit update destroy]
  before_action :set_artist_for_export, only: %i[export]
  before_action :set_page_number, only: %i[index]

  require 'csv'
  require_relative './concerns/sql_queries'
  include DatabaseExecution
  include SQLQueries
  include ArtistMusicSqlHandler

  def index
    authorize Artist, :index?

    per_page = 5
    @total_pages = total_page_of_artist_table(per_page)
    @artists = paginate_artists(per_page)
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
    ActiveRecord::Base.transaction do
      capitalize_artist_enum

      result = create_artist_record(artist_params)

      artist_id = result.first['id']

      create_artist_musics(artist_params[:musics_attributes], artist_id)

      redirect_to artists_path, notice: 'Artist and their musics were successfully created.'
    rescue StandardError => e
      flash.now[:alert] = "Failed to create artist and their musics: #{e.message}"
      render :new
    end
  end

  def edit
    authorize @artist
  end

  def update
    authorize @artist

    ActiveRecord::Base.transaction do
      update_artist_and_music
    end
    redirect_to artists_url, notice: 'Artist updated successfully.'
  rescue ActiveRecord::StatementInvalid
    flash[:alert] = 'Unable to update artist. Please try again.'
  end

  def destroy
    ActiveRecord::Base.transaction do
      delete_artist_and_associated_musics
    end
    redirect_to artists_url, notice: 'Artist deleted successfully.'
  rescue ActiveRecord::StatementInvalid => e
    flash[:alert] = 'Unable to delete artist and musics. Please try again.'
  end

  def export
    csv_data = CsvExportService.export_artists_and_musics

    authorize :artist, :export?

    send_data csv_data, filename: "artists_and_musics-#{Date.today}.csv", type: 'text/csv'
  end

  def import
    file = params[:file]

    authorize :artist, :import?

    ActiveRecord::Base.transaction do
      CsvImportService.import_artists_and_musics(file)
    end
      redirect_to artists_path, notice: 'Artists and Musics were successfully imported.'
  rescue  ActiveRecord::StatementInvalid
      redirect_to artists_path
      flash[:alert] = 'Unable to update artist. Please try again.'
  end

  private

  def artist_params
    params.require(:artist).permit(:date_of_birth, :gender, :full_name,
                                   :address, :first_released_year,
                                   musics_attributes: %i[id genre album_name title _destroy])
  end

  def capitalize_artist_enum
    params[:artist][:gender] = artist_params[:gender]&.capitalize
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
