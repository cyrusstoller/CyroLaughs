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
    
    it "should have unique serial numbers" do
      v1 = Factory(:video, :serial_number => "ABC123")
      v2 = Factory.build(:video, :serial_number => "ABC123")
      v2.should_not be_valid
    end
  end
  
  describe "serial number accessors" do
    before(:each) do
      @video = Factory(:video, :serial_number => "1ABC")
    end
    
    it "should return the video_id" do
      @video.v_id.should == "ABC"
    end
    
    it "should return the service_id" do
      @video.service_id.should == "1"
    end
  end
  
  describe "display_url" do
    it "should respond to display_url" do
      Video.new.should respond_to(:display_url)
    end
    
    it "should return a youtube url" do
      video = Factory(:video, :serial_number => "#{APP_CONFIG["YouTube"]}ABC")
      video.display_url.should == "http://www.youtube.com/watch?v=ABC"
    end
    
    it "should return a vimeo url" do
      video = Factory(:video, :serial_number => "#{APP_CONFIG["Vimeo"]}ABC")
      video.display_url.should == "http://vimeo.com/ABC"
    end
    
    it "should return nil if the service id invalid" do
      video = Factory(:video, :serial_number => "0ABC")
      video.display_url.should be_nil
    end
  end
  
  describe "finding videos with_url" do
    it "should respond to with_url" do
      Video.should respond_to(:with_url)
    end
    
    it "should return nil when there are no videos at the url in the database" do
      Video.with_url("http://www.google.com/").should be_nil
    end
    
    describe "youtube" do
      before(:each) do
        @v_id = "abc"
        @video = Factory(:video, :serial_number => "#{APP_CONFIG["YouTube"]}#{@v_id}")
      end
      
      it "should return @video when using youtube.com" do
        Video.with_url("http://youtube.com/?v=#{@v_id}&q=12344444").should == @video
      end
      
      it "should return @video when using www.youtube.com" do
        Video.with_url("http://www.youtube.com/?v=#{@v_id}&q=222").should == @video
      end
      
      it "should return @video when using youtu.be" do
        Video.with_url("http://youtu.be/#{@v_id}?v=123333").should == @video
      end
    end
    
    describe "vimeo" do
      before(:each) do
        @v_id = "abc"
        @video = Factory(:video, :serial_number => "#{APP_CONFIG["Vimeo"]}#{@v_id}")
      end
      
      it "should return @video when using vimeo.com" do
        Video.with_url("http://vimeo.com/#{@v_id}?v=22").should == @video
      end
      
      it "should return @video when using www.vimeo.com" do
        Video.with_url("http://www.vimeo.com/#{@v_id}?v=33").should == @video
      end
    end
  end
  
  describe "get_details from the service" do
    it "should respond_to :get_details" do
      Video.new.should respond_to(:get_details)
    end
    
    it "should return nil if url is nil" do
      Video.new.get_details.should be_nil
    end
    
    it "should respond to youtube_details" do
      Video.new.should respond_to(:youtube_details)
    end
    
    it "should respond to vimeo_details" do
      Video.new.should respond_to(:vimeo_details)
    end
    
    describe "YouTube.com" do
      it "should add an error to base when there is an invalid url without an id" do
        v = Video.new(:url => "http://www.youtube.com/watch?")
        v.get_details
        v.errors.messages[:base].should_not be_empty
        v.errors.messages[:base].first.should == "Sorry. Please submit the link to the actual video on YouTube, not the search results page."
      end
      
      it "should add an error when youtube prohibits embedding the video" do
        v_id = "_OBlgSz8sSM"
        v = Video.new(:url => "http://www.youtube.com/watch?v=#{v_id}")
        v.stub(:youtube_details).and_return(nil)
        v.get_details
        v.errors.messages[:base].should_not be_empty
        v.errors.messages[:base].first.should == "Sorry. YouTube won't let us embed that video."
      end
      
      it "should add the appropriate title, thumbnail, and duration" do
        v_id = "_OBlgSz8sSM"
        values = {:title => "a", :thumbnail => "http://i.ytimg.com/vi/_OBlgSz8sSM/0.jpg", :duration => 10}
        v = Video.new(:url => "http://www.youtube.com/watch?v=#{v_id}")
        v.stub(:youtube_details).and_return(values)
        v.get_details
        v.title.should == values[:title]
        v.thumb_url.should == values[:thumbnail]
        v.duration.should == values[:duration]
        v.serial_number.should == APP_CONFIG["YouTube"].to_s + v_id
        v.should be_valid
      end
    end
    
    describe "youtu.be" do
      it "should add an error to base when there is an invalid url without an id" do
        v = Video.new(:url => "http://youtu.be/")
        v.get_details
        v.errors.messages[:base].should_not be_empty
        v.errors.messages[:base].first.should == "Sorry. Please submit the link to the actual video on YouTube, not the search results page."
      end
      
      it "should add an error when youtube prohibits embedding the video" do
        v_id = "_OBlgSz8sSM"
        v = Video.new(:url => "http://youtu.be/#{v_id}")
        v.stub(:youtube_details).and_return(nil)
        v.get_details
        v.errors.messages[:base].should_not be_empty
        v.errors.messages[:base].first.should == "Sorry. YouTube won't let us embed that video."
      end
      
      it "should add the appropriate title, thumbnail, and duration" do
        v_id = "_OBlgSz8sSM"
        values = {:title => "a", :thumbnail => "http://i.ytimg.com/vi/_OBlgSz8sSM/0.jpg", :duration => 10}
        v = Video.new(:url => "http://youtu.be/#{v_id}")
        v.stub(:youtube_details).and_return(values)
        v.get_details
        v.title.should == values[:title]
        v.thumb_url.should == values[:thumbnail]
        v.duration.should == values[:duration]
        v.serial_number.should == APP_CONFIG["YouTube"].to_s + v_id
        v.should be_valid
      end
    end
    
    describe "Vimeo" do
      it "should add the appropriate title, thumbnail, and duration" do
        v_id = "_OBlgSz8sSM"
        values = {:title => "a", :thumbnail => "http://i.ytimg.com/vi/_OBlgSz8sSM/0.jpg", :duration => 10}
        v = Video.new(:url => "http://vimeo.com/#{v_id}")
        v.stub(:vimeo_details).and_return(values)
        v.get_details
        v.title.should == values[:title]
        v.thumb_url.should == values[:thumbnail]
        v.duration.should == values[:duration]
        v.serial_number.should == APP_CONFIG["Vimeo"].to_s + v_id
        v.should be_valid
      end
    end
    
    describe "non-youtube or vimeo" do
      it "should return an error" do
        v = Video.new(:url => "http://www.flash.com/watch?")
        v.get_details
        v.errors.messages[:base].should_not be_empty
        v.errors.messages[:base].first.should == "Sorry. Right now we only support videos hosted on YouTube and Vimeo."
      end
    end
    
    describe "when there is an error" do
      it "should return an error" do
        v_id = "_OBlgSz8sSM"
        v = Video.new(:url => "http://www.youtube.com/watch?v=#{v_id}")
        v.stub(:youtube_details).and_return([])
        v.get_details
        v.errors.messages[:base].should_not be_empty
        v.errors.messages[:base].first.should == "Sorry. Can you double check that you submitted a valid YouTube or Vimeo url?"
      end
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
