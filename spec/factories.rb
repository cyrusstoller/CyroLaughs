Factory.sequence :username do |n|
  "username#{n}"
end

Factory.sequence :email do |n|
  "name#{n}@knolcano.com"
end

Factory.define :user do |user|
  user.username   "cyrus"
  user.email      "cyrus@knolcano.com"
  user.password   "foobar"
end

Factory.define :video do |video|
  video.title     "title"
  video.duration  31
  video.user_id   1
end