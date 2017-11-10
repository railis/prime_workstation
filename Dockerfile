FROM ruby:2.4.2
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir /worker
WORKDIR /worker
ADD Gemfile /worker/Gemfile
ADD Gemfile.lock /worker/Gemfile.lock
RUN bundle install
ADD . /worker
