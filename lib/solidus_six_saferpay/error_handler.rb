module SolidusSixSaferpay

  class ErrorHandler
    # Use a custom error handler so that host applications can configure their
    # error handling
    def self.handle(error, level: :error)
      Rails.logger.send(level, error)
      Configuration.error_handlers.each do |handler|
        handler.call(error, level: level)
      end
    end
  end
end

