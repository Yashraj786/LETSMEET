# frozen_string_literal: true

# ReferralCode policy — members manage their own codes; admins govern all
class ReferralCodePolicy < ApplicationPolicy
  def index?   = true  # Members can view their own codes (scope handles filtering)
  def show?    = user.role_admin? || record.user_id == user.id
  def create?  = user.role_admin? # Only admins mint new codes (or the system on signup)
  def new?     = create?
  def update?  = user.role_admin?
  def edit?    = update?
  def destroy? = user.role_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.role_admin? ? scope.all : scope.where(user_id: user.id)
    end
  end
end
