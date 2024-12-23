# frozen_string_literal: true

class UserPolicy < ApplicationPolicy

  def index?
    user.super_admin?
  end

  def create?
    user.super_admin?
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
end
