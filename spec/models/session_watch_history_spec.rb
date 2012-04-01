# == Schema Information
# Schema version: 20120401000034
#
# Table name: session_watch_histories
#
#  id         :integer         not null, primary key
#  session_id :string(255)
#  video_id   :integer
#  ip_address :string(255)
#  status     :integer
#  count      :integer
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe SessionWatchHistory do
  describe "validations" do
    it "should not be valid if it's empty" do
      SessionWatchHistory.new.should_not be_valid
    end
    
    it "should not be valid if there is no session id" do
      SessionWatchHistory.new(:video_id => 12, :ip_address => "123.123.131.1").should_not be_valid
    end
    
    it "should not be valid if there is no video id" do
      SessionWatchHistory.new(:session_id => "12", :ip_address => "123.123.131.1").should_not be_valid      
    end
    
    it "should not be valid if there is no ip" do
      SessionWatchHistory.new(:session_id => "123", :video_id => 12).should_not be_valid
    end
    
    it "should be valid if there are session_id, video_id and ip" do
      SessionWatchHistory.new(:session_id => "2131", :video_id => 12, :ip_address => "123.123.131.1").should be_valid
    end
    
    it "should not be valid if there are duplicate entries per video per session" do
      SessionWatchHistory.create!(:session_id => "2131", :video_id => 12, :ip_address => "123.123.131.1")
      SessionWatchHistory.new(:session_id => "2131", :video_id => 12, :ip_address => "123.123.131.1").should_not be_valid
    end
    
    it "should not be valid if there are duplicate entries per video per user" do
      SessionWatchHistory.create!(:session_id => "2131", :video_id => 12, :ip_address => "123.123.131.1", :user_id => 1)
      SessionWatchHistory.new(:session_id => "2123131", :video_id => 12, :ip_address => "123.123.131.1", :user_id => 1).should_not be_valid
    end
  end
  
  describe "connections" do
    it "should respond to user" do
      SessionWatchHistory.new.should respond_to(:user)
    end
    
    it "should respond to video" do
      SessionWatchHistory.new.should respond_to(:video)
    end
  end
end
