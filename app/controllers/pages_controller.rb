class PagesController < ApplicationController
  def about
  end

  def contact
  end

  def submit_contact
  # Example: handle form data
  name = params[:name]
  email = params[:email]
  message = params[:message]

  # For now just redirect with a flash message
  flash[:notice] = "Thank you! Your message has been received."
  redirect_to contact_path
end


end
