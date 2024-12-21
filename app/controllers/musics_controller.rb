class MusicsController < ApplicationController
  before_action :set_music, only: [:show, :edit, :destroy]

  def index
    @musics = policy_scope(Music)
    @musics = current_user&.artist&.musics
  end

  def new
    @music = Music.new
  end

  def create
  end

  def show
    authorize @music
  end

  def edit
    authorize @music
  end

  def destroy
    authorize @music

    if @music.destroy
      redirect_to musics_path, notice: 'Music was successfully deleted.'
    else
      redirect_to musics_path, alert: 'Failed to delete Music. Please try again.'
    end
  end

  private

  def set_music
    @music = Music.find(params[:id])
  end

  def music_params
    params.require(:music).permit(:title, :album_name, :genre)
  end
end
