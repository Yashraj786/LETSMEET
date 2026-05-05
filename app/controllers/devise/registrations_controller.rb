# frozen_string_literal: true

# Override Devise's RegistrationsController to enforce the referral code gate.
# No valid invitation token → no account. Full stop.
class Devise::RegistrationsController < DeviseController
  # Preserve Devise's standard before_action stack
  prepend_before_action :require_no_authentication, only: [ :new, :create, :cancel ]
  prepend_before_action :authenticate_scope!, only: [ :edit, :update, :destroy ]

  include Devise::Controllers::Helpers

  def new
    @invitation = find_invitation
    # Bounce anyone arriving without a valid invitation token
    redirect_to root_path, alert: "An invitation is required to join LetsMeet." and return unless @invitation

    build_resource({})
    yield resource if block_given?
    respond_with resource
  end

  def create
    @invitation = find_invitation
    unless @invitation
      redirect_to root_path, alert: "Invalid or expired invitation."
      return
    end

    build_resource(sign_up_params)
    resource.referral_code_used = @invitation.referral_code.token
    resource.invited_by         = @invitation.sender

    if resource.save
      @invitation.accept!
      @invitation.referral_code.consume!

      # Dispatch async welcome job — keeps the request cycle tight
      WelcomeEmailJob.perform_later(resource.id)

      set_flash_message! :notice, :signed_up
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      yield resource if block_given?
      respond_with resource
    end
  end

  protected

  def after_sign_up_path_for(resource)
    dashboard_path
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  private

  def find_invitation
    token = params[:invitation_token] || params.dig(:user, :invitation_token)
    return nil if token.blank?

    inv = Invitation.active.find_by(token: token)
    return nil unless inv

    # Prevent recycling a token for a different email if email is already present
    if params.dig(:user, :email).present?
      return nil unless inv.recipient_email.casecmp?(params.dig(:user, :email))
    end

    inv
  end
end
