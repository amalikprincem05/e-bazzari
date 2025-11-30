class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :capture_referral_code

  protected

  def configure_permitted_parameters
    additional_keys = %i[first_name last_name phone address cnic referral_code_input]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_keys)
  end

  private

  def capture_referral_code
    return unless params[:ref].present?

    session[:pending_referral_code] = params[:ref].to_s.strip.upcase
  end
end
