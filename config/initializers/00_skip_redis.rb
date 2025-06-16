# This file is intentionally left empty as we're using a real Redis instance during build
# The Redis configuration is handled by environment variables 

# Skip Redis initialization during asset precompilation and build
if ENV['RAILS_ENV'] == 'production' && (ENV['ASSET_PRECOMPILE'] == 'true' || ENV['BUILD'] == 'true')
  # Create a mock Redis client that returns nil for all operations
  class MockRedis
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