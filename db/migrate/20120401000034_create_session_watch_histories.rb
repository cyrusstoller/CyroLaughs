class CreateSessionWatchHistories < ActiveRecord::Migration
  def change
    create_table :session_watch_histories do |t|
      t.string    :session_id
      t.integer   :video_id
      t.string    :ip_address
      t.integer   :status, :default => 0
      t.integer   :count,  :default => 0
      t.integer   :user_id
      
      t.timestamps
    end

    add_index :session_watch_histories, :session_id
    add_index :session_watch_histories, :video_id
    add_index :session_watch_histories, :ip_address
    add_index :session_watch_histories, :user_id
  end
end
