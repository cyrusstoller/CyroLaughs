class AuthenticationsController < ApplicationController
  def create
    omniauth = request.env["omniauth.auth"]
    
    user = User.find_by_uid(omniauth['uid']) # see if this user is already signed up
    if user
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
    else
      user = User.find_by_email(omniauth["info"]["email"])
      if user
        # someone has already registered with that email address
        user.apply_omniauth(omniauth)
        user.save
        
        flash[:notice] = "Signed in successfully. Facebook account has been added to your account."
        sign_in_and_redirect(:user, user)
      else
        # completely new
        user = User.new
        user.password = SecureRandom.hex(4)        
        user.apply_omniauth(omniauth)
                
        if user.save
          flash[:notice] = "User created. Signed in successfully."   
          sign_in_and_redirect(:user, user)
        else
          session[:omniauth] = omniauth.except('extra')
          flash[:alert] = "Uh oh! Something went wrong. Can you please register with an email and password?"
          redirect_to new_user_registration_url
        end
      end
    end
  end
  
  def failure
    flash[:alert] = params[:provider].titleize + " Login Error: " + params[:message] || "There was a problem with you logging in with #{params[:provider].titleize}"
    redirect_to root_path
  end
end