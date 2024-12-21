# frozen_string_literal: true

class MusicPolicy < ApplicationPolicy

  def index?
    record&.artist&.user == user
  end

  def edit?
  index?
  end

  def update?
    index?
  end

  def destroy?
  index?
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
