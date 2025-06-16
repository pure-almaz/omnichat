# Skip Redis initialization during build
if ENV['SKIP_REDIS_INITIALIZATION'] == 'true'
  # Create a mock Redis client that returns nil for all operations
  class MockRedisClient
    def get(*)
      nil
    end

    def set(*)
      true
    end

    def expire(*)
      true
    end

    def keys(*)
      []
    end
  end

  # Create a mock connection pool that always returns the mock client
  class MockConnectionPool
    def initialize(*)
      @client = MockRedisClient.new
    end

    def with
      yield @client
    end
  end

  # Replace the global Redis connections with mocks
  $alfred = MockConnectionPool.new
  $velma = MockConnectionPool.new
end

if ENV['RAILS_ENV'] == 'production' && ENV['SKIP_REDIS'] == 'true'
  require 'redis'
  require 'redis-namespace'
  require 'connection_pool'

  # Mock the Redis client at the lowest level
  module RedisClient
    class RubyConnection
      def initialize(*args)
        # Do nothing, prevent actual connection
      end

      def connect
        # Do nothing, prevent actual connection
      end

      def connected?
        true
      end

      def disconnect
        # Do nothing
      end

      def call_v(command)
        nil
      end
    end
  end

  # Mock Redis class
  class Redis
    def initialize(*args)
      # Do nothing
    end

    def get(*args)
      nil
    end

    def set(*args)
      true
    end

    def del(*args)
      true
    end

    def exists?(*args)
      false
    end

    def keys(*args)
      []
    end

    def flushdb
      true
    end

    def quit
      true
    end

    def close
      true
    end
  end

  # Mock Redis::Namespace
  class Redis::Namespace
    def initialize(*args)
      # Do nothing
    end

    def get(*args)
      nil
    end

    def set(*args)
      true
    end

    def del(*args)
      true
    end

    def exists?(*args)
      false
    end

    def keys(*args)
      []
    end

    def flushdb
      true
    end

    def quit
      true
    end

    def close
      true
    end
  end

  # Mock ConnectionPool
  class ConnectionPool
    def initialize(*args)
      # Do nothing
    end

    def with
      yield Redis.new
    end
  end

  # Override Redis.new to return our mock
  def Redis.new(*args)
    Redis::Namespace.new('chatwoot', redis: Redis.new)
  end
end 