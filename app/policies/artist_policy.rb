# frozen_string_literal: true

class ArtistPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.artist_manager?
  end

  def show?
    index?
  end

  def create?
    user.artist_manager?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      if user.super_admin? || user.artist_manager
        scope.all    # Artist managers and super admin  can see all artists
      else
        scope.none
      end
    end
  end
end
