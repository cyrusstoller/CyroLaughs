# == Schema Information
# Schema version: 20120331234716
#
# Table name: videos
#
#  id                     :integer         not null, primary key
#  current_week_net_votes :integer
#  current_week_num_votes :integer
#  overall_net_votes      :integer
#  overall_num_votes      :integer
#  title                  :string(255)
#  duration               :integer
#  thumb_url              :string(255)
#  serial_number          :string(255)
#  hash_permalink_id      :integer
#  user_id                :integer
#  hidden                 :boolean
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

require 'spec_helper'

describe Video do
  pending "add some examples to (or delete) #{__FILE__}"
end
