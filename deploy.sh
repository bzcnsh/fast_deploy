#!/bin/bash
DB_USER=myapp
DB_PASS=password1

sudo apt-get update
if [[ "$ROLE"=="DB" ]]; then
  sudo apt-get install -y postgresql postgresql-contrib
  sudo -i -u postgres psql -c "create role $DB_USER with createdb login password '$DB_PASS'"   
fi

if [[ "$ROLE"=="WEB" ]]; then
  sudo apt-get install -y ruby-full build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool
  sudo gem install rails
  sudo gem install bundler
  git clone $web_repo
  pushd webrepo
  bundle install
  export RAILS_EN=production
  rake db:setup
  rails server
  popd
fi
