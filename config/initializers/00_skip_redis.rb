# Skip Redis initialization during build
if ENV['SKIP_REDIS_INITIALIZATION'] == 'true'
  module Redis
    class Client
      def initialize(*args)
        # Do nothing during build
      end
    end
  end

  module ConnectionPool
    def self.new(*args)
      # Return a mock pool during build
      Object.new.tap do |pool|
        def pool.with
          yield nil
        end
      end
    end
  end
end 