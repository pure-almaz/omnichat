FROM ruby:3.3.3 as builder

# Set environment variables first
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=73f123eee412a73f4a06d15c4f1b57feb4a0350f452332aba37393f0f53a19c447e59824b9d2f43a3b210520f60e4936fbe4cdbec16b54e435a61769211de301
ENV REDIS_URL=redis://localhost:6379
ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV REDIS_PASSWORD=
ENV REDIS_DB=0
ENV REDIS_OPENSSL_VERIFY_MODE=none

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    git \
    curl \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    redis-server

# Start Redis server
RUN service redis-server start

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install correct Bundler version
RUN gem install bundler:2.5.16

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Create necessary directories
RUN mkdir -p log tmp/pids tmp/sockets

# Precompile assets
RUN bundle exec rails assets:precompile

# Final stage
FROM ruby:3.3.3

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    git \
    curl \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install correct Bundler version
RUN gem install bundler:2.5.16

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Copy precompiled assets from builder
COPY --from=builder /app/public/assets /app/public/assets
COPY --from=builder /app/public/packs /app/public/packs

# Create necessary directories
RUN mkdir -p log tmp/pids tmp/sockets

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV INSTALLATION_ENV=docker

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] 