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

require "open-uri"
require 'yajl'
require 'cgi'

class Video < ActiveRecord::Base
  attr_accessible :url, :hidden
  attr_accessor :url
  
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_nil => :true
  validates_uniqueness_of :serial_number, :message => "already taken. Someone has already sumbitted this link."
  
  before_validation :get_details
  after_create :add_hash_permalink_id
  
  has_many :views, :class_name => "SessionWatchHistory", :foreign_key => "video_id"
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  
  def v_id
    serial_number[1..-1]
  end
  
  def service_id
    begin
      serial_number[0]
    rescue
      nil
    end
  end
  
  def display_url
    case service_id.to_i
    when APP_CONFIG["YouTube"].to_i
      "http://www.youtube.com/watch?v=#{self.v_id}"
    when APP_CONFIG["Vimeo"].to_i
      "http://vimeo.com/#{self.v_id}"
    end
  end
  
  def self.with_url(url)
    url_components = URI.split(url)
    begin
      case url_components[2].downcase
      when "youtube.com", "www.youtube.com", "youtu.be", "www.youtu.be"
        service_id = APP_CONFIG["YouTube"]
        if url_components[2].downcase == "youtu.be"
          v_id = url_components[5][1..-1]
        else
          v_id = CGI::parse(url_components[7])["v"].first
        end
        serial_number = service_id.to_s + v_id.to_s
      when "vimeo.com", "www.vimeo.com"
        service_id = APP_CONFIG["Vimeo"]
        v_id = url_components[5][1..-1] #getting rid of the leading '/'
        serial_number = service_id.to_s + v_id.to_s
      end
      # puts serial_number
      Video.where("serial_number = :s", :s => serial_number).first
    rescue
      nil
    end
  end
  
  def get_details
    return if url.nil? #to allow for command line modifications
    url_components = URI.split(url)    
    begin
      case url_components[2].downcase
      when "youtube.com", "www.youtube.com", "youtu.be", "www.youtu.be"
        service_id = APP_CONFIG["YouTube"]
        if url_components[2].downcase == "youtu.be"
          v_id = url_components[5][1..-1] #to get rid of the leading slash
        else
          v_id = CGI::parse(url_components[7])["v"].first
        end
        if v_id.blank? or v_id.nil?
          errors[:base] << "Sorry. Please submit the link to the actual video on YouTube, not the search results page."
          return
        end
        meta_data = youtube_details(v_id)
        if meta_data.nil?
          errors[:base] << "Sorry. YouTube won't let us embed that video."
          return
        end
        self.title = meta_data[:title]
        self.thumb_url = meta_data[:thumbnail]
        self.duration = meta_data[:duration]
        self.serial_number = service_id.to_s + v_id.to_s
      when "vimeo.com", "www.vimeo.com"
        service_id = APP_CONFIG["Vimeo"]
        v_id = url_components[5][1..-1] #getting rid of the leading '/'
        meta_data = vimeo_details(v_id)
        self.title = meta_data[:title]
        self.thumb_url = meta_data[:thumbnail]
        self.duration = meta_data[:duration]
        self.serial_number = service_id.to_s + v_id.to_s
      else
        errors[:base] << "Sorry. Right now we only support videos hosted on YouTube and Vimeo."
      end
    rescue
      errors[:base] << "Sorry. Can you double check that you submitted a valid YouTube or Vimeo url?"
    end
  end
  
  def youtube_details(v_id)
    meta_data = Nokogiri::HTML(open("http://gdata.youtube.com/feeds/api/videos/#{v_id}"))
    if meta_data.search("noembed").empty?
      return nil
    else
      return {
        :title     => meta_data.search("title").first.text,
        :thumbnail => meta_data.search("thumbnail")[1].attributes["url"].value,
        :duration  => meta_data.search("duration").first.attributes["seconds"].value
      }
    end
  end
  
  def vimeo_details(v_id)
    parser = Yajl::Parser.new
    meta_data = parser.parse(open("http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/#{v_id}"))
    return {
      :title => meta_data["title"],
      :thumbnail => meta_data["thumbnail"],
      :duration => meta_data["duration"]
    }
  end

  protected

  def add_hash_permalink_id
    self.hash_permalink_id = self.id * APP_CONFIG['prime'].to_i & APP_CONFIG['max_id'].to_i
    self.save
  end

end
