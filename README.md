# Cyro Laughs

## Setting up your development environment

Create a `.env` file in your root directory.

```
GMAIL_ACCOUNT=XXX
GMAIL_PASSWORD=XXX
FACEBOOK_APP_ID=XXX
FACEBOOK_APP_SECRET=XXX
ADMIN_USER=XXX
ADMIN_PASSWORD=XXX
```

```
$ bundle install
$ rake db:create # first time only
$ rake db:migrate # only if you updated the database
$ foreman start
$ bundle exec autotest
```

## Deploying on Heroku

```
$ heroku run rake db:create
$ heroku run rake db:migrate
$ heroku run rake db:seed
$ heroku config:add GMAIL_ACCOUNT=XXX
$ heroku config:add GMAIL_PASSWORD=XXX
$ heroku config:add FACEBOOK_APP_ID=XXX
$ heroku config:add FACEBOOK_APP_SECRET=XXX
$ heroku config:add ADMIN_USER=XXX
$ heroku config:add ADMIN_PASSWORD=XXX
$ git push heroku master
```