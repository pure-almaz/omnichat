# Skip Redis initialization during build
if ENV['SKIP_REDIS_INITIALIZATION'] == 'true' || ENV['SKIP_REDIS'] == 'true'
  require 'redis'
  require 'redis-namespace'
  require 'connection_pool'

  # Create a mock Redis instance
  class MockRedis
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

    def ping
      'PONG'
    end

    def info
      {}
    end
  end

  # Create a mock namespace
  class MockNamespace
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

    def ping
      'PONG'
    end

    def info
      {}
    end
  end

  # Create a mock connection pool
  class MockPool
    def initialize(*args)
      # Do nothing
    end

    def with
      yield MockNamespace.new
    end
  end

  # Replace the global Redis connections with mocks
  $alfred = MockPool.new
  $velma = MockPool.new

  # Override Redis.new to return our mock
  class Redis
    class << self
      alias_method :original_new, :new
      def new(*args)
        MockRedis.new
      end
    end
  end

  # Override Redis::Namespace.new to return our mock
  class Redis::Namespace
    class << self
      alias_method :original_new, :new
      def new(*args)
        MockNamespace.new
      end
    end
  end
end 