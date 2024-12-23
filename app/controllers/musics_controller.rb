# frozen_string_literal: true

class MusicsController < ApplicationController
  before_action :set_music, only: %i[show edit destroy update]

  include ArtistMusicSqlHandler
  require_relative './concerns/sql_queries'
  include DatabaseExecution

  def index
    authorize Music, :index?

    @musics = current_user&.artist&.musics
  end

  def new
    @music = Music.new
    authorize @music
  end

  def create
    authorize :music, :create?

    artist_id = current_user&.artist&.id

    ActiveRecord::Base.transaction do
      @music = create_music(artist_id, music_params)

      redirect_to musics_path, notice: 'Music was successfully created.'
    end
  rescue StandardError => e
    Rails.logger.error("Music creation failed: #{e.message}")
    render :new, alert: 'Music creation failed. Please try again.'
  end

  def show
    authorize @music
  end

  def edit
    authorize @music
  end

  def update
    authorize @music

    ActiveRecord::Base.transaction do
      success = update_music_single(@music.id, music_params)

      raise ActiveRecord::Rollback, 'Music update failed' unless success

      redirect_to musics_path, notice: 'Music was successfully updated.'
    end
  rescue StandardError => e
    Rails.logger.error("Music update failed: #{e.message}")
    render :edit, status: :unprocessable_entity, alert: 'Music update failed. Please try again.'
  end

  def destroy
    authorize @music

    ActiveRecord::Base.transaction do
      success = delete_music(@music.id)

      raise ActiveRecord::Rollback, 'Music deletion failed' unless success

      redirect_to musics_path, notice: 'Music was successfully deleted.'
    end
  rescue StandardError => e
    Rails.logger.error("Music deletion failed: #{e.message}")
    redirect_to musics_path, alert: 'Failed to delete Music. Please try again.'
  end

  private

  def set_music
    @music = find_music_by_id(params[:id])
    raise ActiveRecord::RecordNotFound, 'Music not found' unless @music
  end

  def music_params
    params.require(:music).permit(:title, :album_name, :genre)
  end
end
