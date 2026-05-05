# Dispatched immediately after a new invitation record is persisted.
# Using Sidekiq via :sidekiq queue adapter for high-throughput delivery.
class InvitationEmailJob < ApplicationJob
  queue_as :mailers

  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)

    # Guard: skip if already accepted or revoked before the job ran
    return unless invitation.pending?

    InvitationMailer.invite(invitation).deliver_now
  end
end
