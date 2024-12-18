# frozen_string_literal: true

module ApplicationHelper
  def humanized_roles
    User.roles.keys.map do |role|
      [role.split('_').map(&:capitalize).join(' '), role]
    end
  end

  def humanized_gender_names
    User.genders.keys.map { |gender| [gender.capitalize, gender] }
  end
end
