class ArtistPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.artist_manager?
  end

  def show?
    index? || user.artist?
  end

  
  def create?
    user.artist_manager?
  end

  
  def update?
    create?
  end

  def destroy?
    create?
  end
end
