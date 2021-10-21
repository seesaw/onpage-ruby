# frozen_string_literal: true

module OnPage
  module Api
    # OnPage::Api::RequestCounter
    class RequestCounter
      def initialize
        @semaphore = Mutex.new
        @counter = 0
      end

      def inc!
        @semaphore.synchronize { @counter += 1 }
      end

      def counter
        @semaphore.synchronize { @counter }
      end

      def reset!
        @semaphore.synchronize { @counter = 0 }
      end
    end
  end
end
