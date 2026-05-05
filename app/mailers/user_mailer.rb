class UserMailer < ApplicationMailer
  # Welcome email dispatched after the new member confirms their account
  def welcome(user)
    @user             = user
    @display_name     = user.display_name
    @referral_code    = user.referral_codes.active.first
    @dashboard_url    = dashboard_url

    mail(
      to:      user.email,
      subject: "Welcome to LetsMeet — your membership is confirmed"
    )
  end
end
