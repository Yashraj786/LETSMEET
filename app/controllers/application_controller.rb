class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # ---------------------------------------------------------------------------
  # Pundit — include authorization helpers and enforce coverage on every action
  # ---------------------------------------------------------------------------
  include Pundit::Authorization

  # Surface Pundit::NotAuthorizedError as a friendly redirect rather than a 500
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Force authentication on all pages except Devise routes and the landing page
  before_action :authenticate_user!, unless: :devise_or_public_route?

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:alert] = I18n.t("pundit.#{policy_name}.#{exception.query}",
                           default: "You are not authorised to perform this action.")
    redirect_back(fallback_location: root_path)
  end

  def devise_or_public_route?
    devise_controller? || (controller_name == "pages" && action_name == "home")
  end
end
