FROM ruby:3.3.0

# Set default environment to development (can be overridden at build/run)
ENV RAILS_ENV=development \
    RACK_ENV=development \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/gems

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client \
  nodejs \
  yarn \
  curl \
  imagemagick \
  wkhtmltopdf \
  libvips

# Set working directory
WORKDIR /myapp

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    if [ "$RAILS_ENV" = "development" ]; then \
      bundle install; \
    else \
      bundle install --without development test; \
    fi

# Copy the app
COPY . .

# Precompile assets (only in production)
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle exec rake assets:precompile; \
    fi

# Setup entrypoint
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
