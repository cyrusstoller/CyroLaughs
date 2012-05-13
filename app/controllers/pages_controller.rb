class PagesController < ApplicationController
  def home
    flash.keep
    redirect_to video_path(get_queued_video, :g => SecureRandom.hex(10))
  end
  
  def about
    @title = "About"
  end
  
  def recent
    @title = "Recently watched"
    
    if signed_in?    
      @videos = current_user.videos_watched.order("session_watch_histories.updated_at DESC, session_watch_histories.created_at DESC").
        paginate(:page => params[:page])
    else
      @videos = Video.joins("INNER JOIN session_watch_histories ON session_watch_histories.video_id = videos.id").
        where("session_watch_histories.session_id = :session_id", :session_id => session[:session_id]).
        order("session_watch_histories.updated_at DESC, session_watch_histories.created_at DESC").paginate(:page => params[:page])
    end
    
    if @videos.empty?
      flash[:notice] = "You haven't watched any movies yet"
      redirect_to get_queued_video
      return
    end
  end
  
  def liked
    @title = "Recently liked"
    
    if signed_in?
      @videos = current_user.videos_liked.order("session_watch_histories.updated_at DESC, session_watch_histories.created_at DESC").
        paginate(:page => params[:page])
    else
      @videos = Video.joins("INNER JOIN session_watch_histories ON session_watch_histories.video_id = videos.id").
        where("session_watch_histories.session_id = :session_id AND session_watch_histories.status = #{APP_CONFIG["Awesome"]}", :session_id => session[:session_id]).
        order("session_watch_histories.updated_at DESC, session_watch_histories.created_at DESC").paginate(:page => params[:page])
    end
    
    if @videos.empty?
      flash[:notice] = "You haven't liked any movies yet"
      redirect_to get_queued_video
      return
    end
  end
end