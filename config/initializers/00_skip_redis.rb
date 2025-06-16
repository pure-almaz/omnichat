# Skip Redis initialization during build
if ENV['SKIP_REDIS_INITIALIZATION'] == 'true'
  # Monkey patch the Redis client to prevent actual connections
  class Redis::Client
    alias_method :original_connect, :connect
    def connect
      # Do nothing during build
      @sock = nil
    end
  end

  # Monkey patch the connection pool to return a mock pool
  class ConnectionPool
    alias_method :original_new, :new
    def self.new(*args)
      if ENV['SKIP_REDIS_INITIALIZATION'] == 'true'
        # Return a mock pool during build
        Object.new.tap do |pool|
          def pool.with
            yield nil
          end
        end
      else
        original_new(*args)
      end
    end
  end
end 