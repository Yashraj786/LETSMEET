class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    # Public landing — showcases the platform without leaking member data
    @stats = {
      members:  User.count,
      hangouts: Hangout.published.count
    }
  end
end
