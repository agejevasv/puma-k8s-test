FROM ruby:3.3

RUN mkdir /app
WORKDIR /app
COPY Gemfile* .
RUN gem install bundler
RUN bundle install
COPY . .
