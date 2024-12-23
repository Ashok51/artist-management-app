# frozen_string_literal: true

class MusicPolicy < ApplicationPolicy

  def index?
    user&.artist?
  end

  def new?
    user&.artist?
  end

  def edit?
    record&.artist&.user == user
  end

  def create?
    user.artist?
  end

  def update?
    record&.artist&.user == user
  end

  def destroy?
    record&.artist&.user == user
  end

  class Scope < Scope
    def resolve
      if user.artist?
        scope.where(artist_id: user&.artist&.id)
      else
        scope.none
      end
    end
  end
end
