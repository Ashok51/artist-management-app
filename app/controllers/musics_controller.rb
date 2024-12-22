class MusicsController < ApplicationController
  before_action :set_music, only: %i[show edit destroy update]

  def index
    @musics = policy_scope(Music)
    authorize @musics
  end

  def new
    @music = Music.new
    authorize @music
  end

  def create
    authorize :music, :create?
    @music = current_user&.artist&.musics&.build(music_params)

    if @music.save
      redirect_to musics_path, notice: 'Music was successfully created.'
    else
      render :new
    end
  end

  def show
    authorize @music
  end

  def edit
    authorize @music
  end

  def update
    authorize @music

    if @music.update(music_params)
      redirect_to musics_path, notice: 'Music was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
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
