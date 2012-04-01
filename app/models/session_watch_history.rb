# == Schema Information
# Schema version: 20120401000034
#
# Table name: session_watch_histories
#
#  id         :integer         not null, primary key
#  session_id :string(255)
#  video_id   :integer
#  ip_address :string(255)
#  status     :integer         default(0)
#  count      :integer         default(0)
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class SessionWatchHistory < ActiveRecord::Base
  attr_accessible :session_id, :video_id, :ip_address, :status, :count, :user_id
  
  validates_presence_of :session_id, :on => :create, :message => "can't be blank"
  validates_presence_of :video_id, :on => :create, :message => "can't be blank"
  validates_presence_of :ip_address, :on => :create, :message => "can't be blank"

  belongs_to :video, :class_name => "Video", :foreign_key => "video_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  scope :per_session, lambda{ |s| where([:session_id, s])}
  validates_uniqueness_of :video_id, :scope => [:session_id]
  validates_uniqueness_of :user_id, :scope => [:video_id], :allow_nil => true
end
