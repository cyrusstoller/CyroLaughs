class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer    :current_week_net_votes, :default => 0
      t.integer    :current_week_num_votes, :default => 0
      t.integer    :overall_net_votes     , :default => 0
      t.integer    :overall_num_votes     , :default => 0
      t.string     :title                 
      t.integer    :duration              , :default => 0
      t.string     :thumb_url             
      t.string     :serial_number         
      t.integer    :hash_permalink_id     
      t.integer    :user_id               
      t.boolean    :hidden                , :default => false
      t.timestamps
    end
    
    add_index :videos, :current_week_net_votes
    add_index :videos, :current_week_num_votes
    add_index :videos, :serial_number
    add_index :videos, :hash_permalink_id
    add_index :videos, :user_id
    add_index :videos, :hidden
  end
end
