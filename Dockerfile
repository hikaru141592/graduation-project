FROM ruby:3.2.2

ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8 \
    TZ=Asia/Tokyo \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends locales tzdata \
      cron \
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

ARG BUNDLER_VERSION=2.6.8

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v ${BUNDLER_VERSION} \
 && bundle _${BUNDLER_VERSION}_ config set --global path "/usr/local/bundle" \
 && bundle _${BUNDLER_VERSION}_ install --jobs 4 --retry 3

COPY . .

EXPOSE 3000

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
