class VideosController < ApplicationController  
  realm = "Are you a cyro laughs admin?"
  http_basic_authenticate_with :name => ENV["ADMIN_USER"], :password => ENV["ADMIN_PASSWORD"], :except => [:show, :new, :create, :rating], 
                               :realm => realm
  before_filter :make_admin_cookie, :except => [:show, :new, :create, :rating]

  helper_method :sort_column, :sort_direction

  # GET /videos
  def index
    @videos = Video.order(sort_column + " " + sort_direction).paginate(:page => params[:page])
    @title = "Video Index"

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    unless signed_in?
      logger.info "figuring out if I should show the sign up page #{@watched_count.to_i} % 7 == #{@watched_count.to_i % 7}"
      if ((@watched_count.to_i % 7) == 6) and params[:g].nil?
        redirect_to new_user_registration_path
        return
      end
    end
    
    @video = Video.find_by_hash_permalink_id(params[:id])
    @title = @video.title

    # tracking data
    if signed_in?
      recent = SessionWatchHistory.where(:video_id => @video.id, :user_id => current_user.id).first
      if recent.nil?
        recent = SessionWatchHistory.new(:video_id => @video.id, :session_id => session[:session_id], :ip_address => request.ip, :user_id => current_user.id)
      end
    else
      recent = SessionWatchHistory.where(:video_id => @video.id, :session_id => session[:session_id]).first
      if recent.nil?
        recent = SessionWatchHistory.new(:video_id => @video.id, :session_id => session[:session_id], :ip_address => request.ip)
      end
    end
    
    recent.count += 1
    recent.status = 0 if recent.status.nil?
    recent.save
        
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /videos/new
  # GET /videos/new.json
  def new
    @video = Video.new
    @title = "Video Submission"
    
    @url = params[:url]
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /videos/1/edit
  def edit
    @video = Video.find_by_hash_permalink_id(params[:id])
    @url = @video.display_url
    
    @title = "Edit Video URL"
  end

  # POST /videos
  # POST /videos.json
  def create    
    @video = Video.new(params[:video])
    
    if signed_in?
      @video.user_id = current_user.id
    end

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render json: @video, status: :created, location: @video }
      else
        existing = Video.with_url(params[:video][:url])
        if existing.nil?
          format.html { render action: "new" }
          format.json { render json: @video.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to existing, notice: 'Video has already been submitted.' }
          format.json { render json: existing, location: @video }
        end
      end
    end
  end

  # PUT /videos/1
  # PUT /videos/1.json
  def update
    @video = Video.find_by_hash_permalink_id(params[:id])

    respond_to do |format|
      if @video.update_attributes(params[:video])
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video = Video.find_by_hash_permalink_id(params[:id])
    @video.destroy

    respond_to do |format|
      format.html { redirect_to videos_url }
      format.json { head :ok }
    end
  end
  
  def rating
    @video = Video.find_by_hash_permalink_id(params[:id])
    
    if signed_in?
      recent = SessionWatchHistory.where(:video_id => @video.id, :user_id => current_user.id).first
    else
      recent = SessionWatchHistory.where(:video_id => @video.id, :session_id => session[:session_id]).first
    end
    
    if recent.nil?
      if signed_in?
        recent = SessionWatchHistory.new(:video_id => @video.id, :session_id => session[:session_id], :ip_address => request.ip, :user_id => current_user.id)
      else
        recent = SessionWatchHistory.new(:video_id => @video.id, :session_id => session[:session_id], :ip_address => request.ip)
      end
      recent.count = 1
      recent.status = APP_CONFIG["Skip"]
      if signed_in?
        recent.user_id = current_user.id
      end
    else
      recent.updated_at = Time.now  
    end
        
    @video.current_week_num_votes += 1
    @video.overall_num_votes += 1
    
    case params[:commit]
    when "Awesome"
        
      case recent.status
      when APP_CONFIG["Skip"]
        @video.current_week_net_votes += 1
        @video.overall_net_votes += 1
      when APP_CONFIG["Dislike"]
        @video.current_week_net_votes += 2
        @video.overall_net_votes += 2
      end
      recent.status = APP_CONFIG["Awesome"]
      
      flash[:notice] = render_to_string(:partial => 'videos/flash_messages/awesome').html_safe
      
      # respond_to do |format|
      #   format.js {
      #     if recent.save
      #       @video.save
      #     end
      #     
      #     if signed_in?
      #       @liked_count = current_user.videos_liked.count
      #     else
      #      @liked_count = Video.joins("INNER JOIN `session_watch_histories` ON `session_watch_histories`.video_id = `videos`.id").
      #         where("`session_watch_histories`.session_id = :session_id AND `session_watch_histories`.status = 1", :session_id => session[:session_id]).
      #         count
      #     end
      #     
      #     render "awesome"
      #     return
      #   }
      # end
    when "Skip", "Meh"
      
      flash[:notice] = render_to_string(:partial => 'videos/flash_messages/skip').html_safe
      
      case recent.status
      when APP_CONFIG["Awesome"]
        @video.current_week_net_votes -= 1
        @video.overall_net_votes -= 1
      when APP_CONFIG["Dislike"]
        @video.current_week_net_votes += 1
        @video.overall_net_votes += 1
      end
      recent.status = APP_CONFIG["Skip"]
    when "Dislike"
      
      flash[:notice] = render_to_string(:partial => 'videos/flash_messages/dislike').html_safe
      
      case recent.status
      when APP_CONFIG["Awesome"]
        @video.current_week_net_votes -= 2
        @video.overall_net_votes -= 2
      when APP_CONFIG["Skip"]
        @video.current_week_net_votes -= 1
        @video.overall_net_votes -= 1
      end
      recent.status = APP_CONFIG["Dislike"]
    end

    if recent.save
      @video.save
    end
    
    redirect_to get_queued_video
  end
  
  protected
  
  def make_admin_cookie
    session[:admin] = "true"
  end
  
  private

  def sort_column
    Video.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
