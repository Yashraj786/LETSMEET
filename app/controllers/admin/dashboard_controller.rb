module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_users:       User.count,
        confirmed_users:   User.where.not(confirmed_at: nil).count,
        total_hangouts:    Hangout.count,
        upcoming_hangouts: Hangout.upcoming.count,
        pending_invites:   Invitation.pending.count,
        active_codes:      ReferralCode.active.available.count
      }

      @recent_users       = User.order(created_at: :desc).limit(10)
      @recent_invitations = Invitation.includes(:sender).order(created_at: :desc).limit(10)
    end
  end
end
