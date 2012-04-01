namespace :weekly_totals do
  desc "Reset counters on all of the videos for the week"
  task :reset => :environment do
    puts "Total number of videos in the system: #{Video.count}"
    Video.all.each do |video|
      puts video.display_url
      video.current_week_num_votes = 0
      video.current_week_net_votes = 0
      video.save
    end
  end
  
  desc "Reset all counters ever set -- DON'T USE unless you are absolutely sure"
  task :hard_reset => :environment do
    puts "Total number of videos in the system: #{Video.count}"
    Video.all.each do |video|
      puts video.display_url
      video.current_week_num_votes = 0
      video.current_week_net_votes = 0
      video.overall_num_votes = 0
      video.overall_net_votes = 0
      video.save
    end
  end
end