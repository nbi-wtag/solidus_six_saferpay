module SolidusSixSaferpay
  class InvalidSaferpayPayment < StandardError
    def initialize(message: "Saferpay Payment is invalid", details: "")
      super("#{message}: #{details}".strip)
    end

    def full_message
      message
    end
  end
end
