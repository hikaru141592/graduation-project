FROM ruby:3.2.2

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update -qq \
  && apt-get install -y \
     build-essential \
     libpq-dev \
     nodejs \
     npm \
     postgresql-client \
     yarn \
     tzdata \
     chromium \
     chromium-driver \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
 && bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
