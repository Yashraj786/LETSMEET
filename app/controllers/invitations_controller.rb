class InvitationsController < ApplicationController
  before_action :set_invitation, only: %i[show revoke]

  def index
    @invitations = policy_scope(Invitation).includes(:referral_code).order(created_at: :desc)
    authorize Invitation
  end

  def show
    authorize @invitation
  end

  def new
    authorize Invitation
    @invitation = Invitation.new
    @referral_codes = current_user.referral_codes.active.available
  end

  def create
    authorize Invitation
    code = current_user.referral_codes.active.available.find_by(id: invitation_params[:referral_code_id])

    unless code
      redirect_to new_invitation_path, alert: "No valid referral code available."
      return
    end

    @invitation = Invitation.new(invitation_params.merge(sender: current_user, referral_code: code))

    if @invitation.save
      InvitationEmailJob.perform_later(@invitation.id)
      redirect_to invitations_path, notice: "Invitation sent to #{@invitation.recipient_email}."
    else
      @referral_codes = current_user.referral_codes.active.available
      render :new, status: :unprocessable_entity
    end
  end

  def revoke
    authorize @invitation, :revoke?
    @invitation.update!(status: :revoked)
    redirect_to invitations_path, notice: "Invitation revoked."
  end

  private

  def set_invitation
    @invitation = Invitation.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:recipient_email, :referral_code_id)
  end
end
