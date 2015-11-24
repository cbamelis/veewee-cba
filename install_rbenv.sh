#!/bin/bash
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone -- https://github.com/carsomyr/rbenv-bundler.git ~/.rbenv/plugins/bundler
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
# restart shell
rbenv rehash
rbenv install 2.2.1
rbenv rehash
gem install bundler
bundle install
