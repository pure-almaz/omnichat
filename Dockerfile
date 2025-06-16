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

# Precompile assets
RUN bundle exec rails assets:precompile

# Expose port
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] 