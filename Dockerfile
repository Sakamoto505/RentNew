FROM ruby:3.3.0-slim

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    git \
    curl \
    file \
    imagemagick \
    libvips-tools && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v 2.4.22

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs 4 --retry 3

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

COPY . .


ENTRYPOINT ["entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3008"]