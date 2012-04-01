# == Schema Information
# Schema version: 20120401000034
#
# Table name: videos
#
#  id                     :integer         not null, primary key
#  current_week_net_votes :integer         default(0)
#  current_week_num_votes :integer         default(0)
#  overall_net_votes      :integer         default(0)
#  overall_num_votes      :integer         default(0)
#  title                  :string(255)
#  duration               :integer         default(0)
#  thumb_url              :string(255)
#  serial_number          :string(255)
#  hash_permalink_id      :integer
#  user_id                :integer
#  hidden                 :boolean         default(FALSE)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

require 'spec_helper'

describe Video do
  describe "validations" do
    it "should not be valid with a non_url submitted as the url" do
      Video.new(:url => "abc").should_not be_valid
    end
    
    it "should be valid with a real url" do
      Video.new(:url => "http://www.google.com").should be_valid
    end
    
    it "should have unique serial numbers" do
      v1 = Factory(:video, :serial_number => "ABC123")
      v2 = Factory.build(:video, :serial_number => "ABC123")
      v2.should_not be_valid
    end
  end
  
  describe "hash_permalink_id" do
    it "should have the right value" do
      video = Factory(:video)
      video.hash_permalink_id.should == video.id * APP_CONFIG['prime'].to_i & APP_CONFIG['max_id'].to_i
    end
  end
  
  describe "connections" do
    it "should respond to views" do
      Video.new.should respond_to(:views)
    end
    
    it "should respond to owner" do
      Video.new.should respond_to(:owner)
    end
  end
end
