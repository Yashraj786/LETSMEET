# frozen_string_literal: true

# Hangout policy — governs CRUD and attendance actions
class HangoutPolicy < ApplicationPolicy
  # Any confirmed member may browse the published hangout listing
  def index?  = user.confirmed?

  # Members can see published hangouts; admins + creator see all states
  def show?
    return true if user.role_admin?
    return true if record.creator_id == user.id
    record.published?
  end

  # Any confirmed member may create a hangout
  def create? = user.confirmed?
  def new?    = create?

  # Only the creator or an admin may edit
  def update?  = user.role_admin? || record.creator_id == user.id
  def edit?    = update?

  # Only admin can hard-delete; creator can cancel (soft)
  def destroy? = user.role_admin?
  def cancel?  = user.role_admin? || record.creator_id == user.id

  # RSVP — any confirmed member can try to join a published, non-full hangout
  def rsvp?
    user.confirmed? && record.published? && !record.full?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.role_admin?
        scope.all
      else
        # Members see all published hangouts + their own drafts/cancelled
        scope.published.or(scope.where(creator_id: user.id))
      end
    end
  end
end
