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