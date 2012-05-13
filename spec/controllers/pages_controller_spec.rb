require 'spec_helper'

describe PagesController do
  render_views
  
  before(:each) do
    @video = Factory(:video)
  end
  
  def create_watch_history(session_id)
    SessionWatchHistory.create!(:session_id => session_id, :video_id => @video.id, :ip_address => "blah", :count => 1, :status => 1)
  end
  
  describe "GET 'home'" do
    it "redirects to video_path" do
      get 'home'
      response.should be_redirect
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
    end
  end

  describe "GET 'recent'" do
    it "returns http success if there is a recently watched video" do
      create_watch_history("woot")
      get 'recent', nil, {:session_id => "woot"}
      response.should be_success
    end
    
    it "should redirect if there are no liked videos" do
      get 'recent'
      response.should redirect_to(@video)
    end
  end

  describe "GET 'liked'" do
    it "returns http success if there is a recently watched video" do
      create_watch_history("woot")
      get 'liked', nil, {:session_id => "woot"}
      response.should be_success
    end
    
    it "should redirect if there are no liked videos" do
      get 'liked'
      response.should redirect_to(@video)
    end
  end

end
