FROM ruby:3.2.2

ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8 \
    TZ=Asia/Tokyo \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends locales tzdata \
      build-essential \
      libpq-dev \
      nodejs \
      npm \
      postgresql-client \
      yarn \
      chromium \
      chromium-driver \
 && sed -i 's/^# *\(ja_JP\.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja LC_ALL=ja_JP.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
 && bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
