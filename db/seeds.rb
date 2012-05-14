# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

initial_links = YAML.load_file("#{Rails.root.to_s}/db/seed_videos.yml")

initial_links.each do |link|
  v = Video.new(:url => link)
  if v.save
    puts "Added: #{link}"
  else
    puts "Failed to add: #{link}"
  end
end