module SolidusSixSaferpay

  class Configuration
    def self.config
      yield(self)
    end

    def self.error_handlers
      @error_handlers ||= []
    end
  end
end
