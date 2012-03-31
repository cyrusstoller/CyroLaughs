require 'spec_helper'

describe PagesController do
  render_views
  
  describe "GET 'home'" do
    it "redirects to about_path" do
      get 'home'
      response.should redirect_to(about_path)
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
    end
  end

  describe "GET 'recent'" do
    it "returns http success" do
      get 'recent'
      response.should be_success
    end
  end

  describe "GET 'liked'" do
    it "returns http success" do
      get 'liked'
      response.should be_success
    end
  end

end
