# Dispatched after a new member successfully registers.
# Sends a curated welcome email and allocates their first referral code.
class WelcomeEmailJob < ApplicationJob
  queue_as :mailers

  def perform(user_id)
    user = User.find(user_id)

    # Mint one referral code for the new member to pass the torch
    user.referral_codes.create!(max_uses: 1) unless user.referral_codes.active.exists?

    UserMailer.welcome(user).deliver_now
  end
end
