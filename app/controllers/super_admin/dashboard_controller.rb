module SuperAdmin
  class DashboardController < BaseController
    def index
      @admins = User.where(admin: true).order(created_at: :desc)
      @customers = User.where(admin: false).order(created_at: :desc)
      @new_admin = User.new(admin: true, created_by_admin: true)
    end
  end
end

