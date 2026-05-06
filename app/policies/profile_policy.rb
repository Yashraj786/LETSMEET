# frozen_string_literal: true

# Profile policy — members manage their own profile; admins can manage all
class ProfilePolicy < ApplicationPolicy
  def show?
    return true if user.role_admin?
    # Profiles are visible to other members if made public, always to the owner
    record.user_id == user.id || record.public_profile?
  end

  # Members can only create/edit their own profile
  def create?  = true
  def new?     = create?
  def update?  = user.role_admin? || record.user_id == user.id
  def edit?    = update?
  def destroy? = user.role_admin? || record.user_id == user.id

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_admin?
        scope.all
      else
        scope.public_profiles.or(scope.where(user_id: user.id))
      end
    end
  end
end
