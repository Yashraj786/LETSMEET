class InvitationMailer < ApplicationMailer
  # Sends the invite email to a prospect with their unique sign-up link
  def invite(invitation)
    @invitation     = invitation
    @sender         = invitation.sender
    @sign_up_url    = new_user_registration_url(invitation_token: invitation.token)
    @expires_at     = invitation.expires_at

    mail(
      to:      invitation.recipient_email,
      subject: "#{@sender.display_name} has invited you to LetsMeet"
    )
  end
end
