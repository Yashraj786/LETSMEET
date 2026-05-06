class HangoutsController < ApplicationController
  before_action :set_hangout, only: %i[show edit update destroy cancel rsvp]

  def index
    @hangouts = policy_scope(Hangout).upcoming.includes(:creator, :hangout_participants)
  end

  def show
    authorize @hangout
    @participants = @hangout.hangout_participants.attending.includes(:user)
  end

  def new
    @hangout = Hangout.new
    authorize @hangout
  end

  def create
    @hangout = current_user.created_hangouts.build(hangout_params)
    authorize @hangout

    if @hangout.save
      redirect_to @hangout, notice: "Hangout created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @hangout
  end

  def update
    authorize @hangout

    if @hangout.update(hangout_params)
      redirect_to @hangout, notice: "Hangout updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @hangout
    @hangout.destroy
    redirect_to hangouts_path, notice: "Hangout removed."
  end

  def cancel
    authorize @hangout, :cancel?
    @hangout.update!(status: :cancelled)
    redirect_to @hangout, notice: "Hangout cancelled."
  end

  # RSVP — accept or decline a hangout invitation
  def rsvp
    authorize @hangout, :rsvp?
    action = params[:rsvp_action].to_sym

    participant = @hangout.hangout_participants.find_or_initialize_by(user: current_user)

    case action
    when :accept
      if @hangout.full?
        participant.assign_attributes(status: :waitlisted)
      else
        participant.assign_attributes(status: :accepted)
      end
    when :decline
      participant.assign_attributes(status: :declined)
    else
      redirect_to @hangout, alert: "Invalid RSVP action." and return
    end

    participant.save!
    redirect_to @hangout, notice: "RSVP recorded."
  end

  private

  def set_hangout
    @hangout = Hangout.find(params[:id])
  end

  def hangout_params
    params.require(:hangout).permit(
      :title, :description, :hangout_type, :location, :meeting_url,
      :starts_at, :ends_at, :max_attendees, :invite_only, :status, :cover_image
    )
  end
end
