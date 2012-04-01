class RegistrationsController < Devise::RegistrationsController
  def create
    session_watch_histories = SessionWatchHistory.where("session_id = :id", :id => session[:session_id])
    super
    session[:omniauth] = nil unless @user.new_record?
    
    session_watch_histories.map do |s|
      s.user_id = @user.id
      s.save
    end
  end
  
  private
  
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end
end