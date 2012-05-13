class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :liked_count
  
  def liked_count
    if signed_in?
      # unique videos
      @liked_count = current_user.videos_liked.count
      @watched_count = current_user.videos_watched.count
    else
      @liked_count = Video.joins("INNER JOIN session_watch_histories ON session_watch_histories.video_id = videos.id").
        where("session_watch_histories.session_id = :session_id AND session_watch_histories.status = 1", :session_id => session[:session_id]).
        count
      @watched_count = Video.joins("INNER JOIN session_watch_histories ON session_watch_histories.video_id = videos.id").
        where("session_watch_histories.session_id = :session_id", :session_id => session[:session_id]).count
    end
  end
  
  def get_queued_video 
    if @watched_count < 3
      res = hall_of_fame
      if res.nil?
        res = random_video
      end
      return res
    else
      seed = Random.rand(20)
      logger.info "random seed for get queued video: #{seed}"
    
      case seed
      when 0..6
        res = hall_of_fame
      when 7..12      
        res = top_this_week
      when 13..15
        res = newly_submitted
      when 16..18
        res = random_video_this_week
      when 19
        res = random_video
      else
        res = random_video
      end
    
      res = newly_submitted if res.nil?
      res = random_video if res.nil?
      
      if signed_in?
        unless SessionWatchHistory.where("video_id = :v_id AND user_id = :user_id", :v_id => res.id, :user_id => current_user.id).empty?
          logger.info "rerouting to a video the user hasn't seen"
          res = random_video
        end
      else
        unless SessionWatchHistory.where("video_id = :v_id AND session_id = :session_id", :v_id => res.id, :session_id => session[:session_id]).empty?
          logger.info "rerouting to a video the user hasn't seen"
          res = random_video
        end
      end
      return res
    end
  end

  protected

  def hall_of_fame
    max_num_offset = Video.count/5 #top 20% of videos unseen
    max_num_offset = 30 if max_num_offset > 30
    current_offset = set_current_offset(max_num_offset)
    logger.info "hall of fame #{max_num_offset} - current offset: #{current_offset}"
    
    if signed_in?
      sql_query = "(videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
      sql_query += "session_watch_histories.user_id = :user_id)) AND overall_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
      Video.where(sql_query, :user_id => current_user.id, :worst_allowed => APP_CONFIG["worst_allowed"]).order("overall_net_votes DESC").
        offset(current_offset).limit(1).first
    else
      sql_query = "(videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
      sql_query += "session_watch_histories.session_id = :session_id)) AND overall_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
      Video.where(sql_query, :session_id => session[:session_id], :worst_allowed => APP_CONFIG["worst_allowed"]).
        order("overall_net_votes DESC").offset(current_offset).limit(1).first
    end
  end
  
  def newly_submitted
    logger.info "newly submitted"
    sql_query = "overall_num_votes < :newly_submitted AND overall_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
    Video.where(sql_query, :newly_submitted => APP_CONFIG["newly_submitted"], :worst_allowed => APP_CONFIG["worst_allowed"]).order("random()").limit(1).first
  end   
  
  def top_this_week
    logger.info "top this week"
    max_num_offset = Video.where("current_week_net_votes > 0").count/5 #top 20% of videos that have positive reviews this week
    current_offset = set_current_offset(max_num_offset)

    if signed_in?
      sql_query = "(videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
      sql_query += "session_watch_histories.user_id = :user_id)) AND current_week_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
      Video.where(sql_query, :user_id => current_user.id, :worst_allowed => APP_CONFIG["worst_allowed"]).
        order("current_week_net_votes DESC").offset(current_offset).limit(1).first
    else
      sql_query = "(videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
      sql_query += "session_watch_histories.session_id = :session_id)) AND current_week_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
      Video.where(sql_query, :session_id => session[:session_id], :worst_allowed => APP_CONFIG["worst_allowed"]).
        order("current_week_net_votes DESC").offset(current_offset).limit(1).first
    end
  end
  
  def random_video_this_week
    logger.info "random video this week"
    Video.where("created_at >= :time AND current_week_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)", :time => Time.now - 7.days, 
      :worst_allowed => APP_CONFIG["worst_allowed"]).order("random()").limit(1).first
  end
  
  def random_video
    logger.info "random video"
    
    if signed_in?
      if SessionWatchHistory.where("user_id = :user_id", :user_id => current_user.id).count == Video.count
        flash[:info] = render_to_string(:partial => 'videos/flash_messages/please_add').html_safe
        return Video.order("random()").limit(1).first
      else
        sql_query = "(videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
        sql_query += "session_watch_histories.user_id = :user_id)) AND overall_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
        res = Video.where(sql_query, :user_id => current_user.id, :worst_allowed => APP_CONFIG["worst_allowed"]).
          order("random()").limit(1).first
        if res.nil?
          flash[:info] = render_to_string(:partial => 'videos/flash_messages/only_negative').html_safe
          sql_query = "videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
          sql_query += "session_watch_histories.user_id = :user_id) AND (hidden = false OR hidden IS NULL)"
          res = Video.where(sql_query, :user_id => current_user.id).order("random()").limit(1).first          
          if res.nil?
            return Video.order("random()").limit(1).first
          end
        end
        return res
      end
    else
      # not signed in
      if SessionWatchHistory.where("session_id = :session_id", :session_id => session[:session_id]).count == Video.count
        flash[:info] = render_to_string(:partial => 'videos/flash_messages/please_add').html_safe
        return Video.order("random()").limit(1).first
      else
        sql_query = "(videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
        sql_query += "session_watch_histories.session_id = :session_id)) AND overall_net_votes >= :worst_allowed AND (hidden = false OR hidden IS NULL)"
        res = Video.where(sql_query, :session_id => session[:session_id], :worst_allowed => APP_CONFIG["worst_allowed"]).
          order("random()").limit(1).first
        if res.nil?
          flash[:info] = render_to_string(:partial => 'videos/flash_messages/only_negative').html_safe
          sql_query = "videos.id NOT IN (SELECT session_watch_histories.video_id FROM session_watch_histories WHERE "
          sql_query += "session_watch_histories.session_id = :session_id) AND (hidden = false OR hidden IS NULL)"
          res = Video.where(sql_query, :session_id => session[:session_id]).order("random()").limit(1).first          
          if res.nil?
            return Video.order("random()").limit(1).first
          end
        end
        return res
      end
    end
  end
  
  private
  
  def set_current_offset(max_offset)
    return 0 if max_offset < 1
    return Random.rand(max_num_offset).to_i
  end
  
end
