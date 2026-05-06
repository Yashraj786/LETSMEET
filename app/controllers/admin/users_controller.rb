module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy grant_admin revoke_admin
                                      mint_referral_code]

    def index
      @users = User.includes(:profile, :referral_codes).order(created_at: :desc)
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User removed from the network."
    end

    def grant_admin
      @user.update!(role: :admin)
      redirect_to admin_user_path(@user), notice: "#{@user.display_name} is now an admin."
    end

    def revoke_admin
      @user.update!(role: :member)
      redirect_to admin_user_path(@user), notice: "Admin privileges revoked."
    end

    # Mint a fresh referral code and assign it to the selected user
    def mint_referral_code
      code = @user.referral_codes.create!(
        max_uses:   params.fetch(:max_uses, 1).to_i,
        expires_at: params[:expires_at].present? ? Time.zone.parse(params[:expires_at]) : nil
      )
      redirect_to admin_user_path(@user), notice: "Referral code #{code.token} minted."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :role)
    end
  end
end
