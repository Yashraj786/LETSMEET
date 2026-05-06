# frozen_string_literal: true

# Invitation policy — members can send invites with available referral codes;
# admins have full control over the invitation pipeline.
class InvitationPolicy < ApplicationPolicy
  def index?  = user.role_admin? || record == user
  def show?   = user.role_admin? || record.sender_id == user.id
  def create? = user.confirmed? && user.can_invite?
  def new?    = create?
  def destroy? = user.role_admin? || record.sender_id == user.id

  # Revoke is a soft-delete — only sender or admin
  def revoke? = user.role_admin? || record.sender_id == user.id

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.role_admin? ? scope.all : scope.where(sender_id: user.id)
    end
  end
end
