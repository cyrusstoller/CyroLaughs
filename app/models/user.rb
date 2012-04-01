# == Schema Information
# Schema version: 20120401000034
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  password_salt          :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer         default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  authentication_token   :string(255)
#  username               :string(255)
#  admin                  :boolean
#  fb_token               :string(255)
#  uid                    :integer
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :username, :remember_me #:password_confirmation
  # attr_accessible :title, :body
  
  #to allow a user to sign in using either thier username or email
  attr_accessor :login
  attr_accessible :login

  validates_uniqueness_of :username, :on => :create, :message => "must be unique", :case_sensitive => false, :allow_nil => true, :allow_blank => true
  validates_length_of :username, :within => 3..15, :on => :create, :allow_nil => true, :allow_blank => true
  validates_format_of :username, :with => /^[\w\d]+$/, :allow_nil => true, :allow_blank => true
  
  before_save :reset_authentication_token
  
  has_many :videos_submitted, :class_name => "Video", :foreign_key => "user_id"
  
  has_many :watch_history, :class_name => "SessionWatchHistory", :foreign_key => "user_id"
  has_many :videos_watched, :class_name => "Video", :through => :watch_history, :source => :video
  
  has_many :videos_liked, :class_name => "Video", :through => :watch_history, :source => :video, 
    :conditions => "`session_watch_histories`.status = #{APP_CONFIG["Awesome"]}"

  def apply_omniauth(omniauth)
    self.email = omniauth['info']['email'] if email.blank?
    self.uid = omniauth['uid']
    self.fb_token = omniauth['credentials']['token']
  end

  def display_name
    return username unless username.nil? or username.blank?
    return email.split("@")[0]
  end
  
  protected    

  def self.find_for_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end
end
