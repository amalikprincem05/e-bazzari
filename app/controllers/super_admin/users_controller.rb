module SuperAdmin
  class UsersController < BaseController
    before_action :set_user, only: %i[promote_to_admin demote_to_user]

    def create_admin
      @new_admin = User.new(user_params.merge(admin: true, created_by_admin: true))

      if @new_admin.save
        redirect_to super_admin_dashboard_path, notice: 'Admin account created successfully.'
      else
        load_dashboard_data
        flash.now[:alert] = 'Unable to create admin account.'
        render 'super_admin/dashboard/index', status: :unprocessable_entity
      end
    end

    def promote_to_admin
      if @user.update(admin: true)
        redirect_to super_admin_dashboard_path, notice: "#{@user.full_name} is now an admin."
      else
        redirect_to super_admin_dashboard_path, alert: @user.errors.full_messages.to_sentence
      end
    end

    def demote_to_user
      if @user.super_admin?
        redirect_to super_admin_dashboard_path, alert: "You can't demote a super admin."
      elsif @user.update(admin: false)
        redirect_to super_admin_dashboard_path, notice: "#{@user.full_name} is now a customer."
      else
        redirect_to super_admin_dashboard_path, alert: @user.errors.full_messages.to_sentence
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :cnic, :password, :password_confirmation)
    end

    def load_dashboard_data
      @admins = User.where(admin: true).order(created_at: :desc)
      @customers = User.where(admin: false).order(created_at: :desc)
      @new_admin ||= User.new(admin: true, created_by_admin: true)
    end
  end
end

