module SuperAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_super_admin!

    private

    def ensure_super_admin!
      return if current_user&.super_admin?

      redirect_to root_path, alert: 'Access denied. Super admin privileges required.'
    end
  end
end

