class DashboardController < ApplicationController
  def index
    @upcoming_hangouts  = policy_scope(Hangout).upcoming.limit(6)
    @my_hangouts        = current_user.created_hangouts.order(starts_at: :desc).limit(5)
    @pending_invitations = current_user.sent_invitations.pending.limit(5)
    @referral_codes     = current_user.referral_codes.active.available
  end
end
