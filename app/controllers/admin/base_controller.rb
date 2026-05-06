module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      redirect_to root_path, alert: "Access denied." unless current_user&.role_admin?
    end
  end
end
