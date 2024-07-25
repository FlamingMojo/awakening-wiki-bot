FROM ruby:3.2.2

WORKDIR /awakening-wiki-bot
RUN gem install bundler

COPY . .
RUN bundle install

ENTRYPOINT ["./entrypoint.sh"]
