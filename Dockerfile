FROM ruby:3.2

WORKDIR /app

ENV MAKE="make --jobs 8"

COPY . .

RUN bundle install

CMD bundle exec rake