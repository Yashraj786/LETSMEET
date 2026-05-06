class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show edit update]

  def show
    authorize @profile
  end

  def edit
    authorize @profile
  end

  def update
    authorize @profile

    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(
      :display_name, :bio, :location, :website, :public_profile,
      :avatar, :cover_photo,
      interests: []
    )
  end
end
