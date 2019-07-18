module SolidusSixSaferpay

  class GatewayResponse
    attr_reader :api_response, :message, :test, :error_name, :authorization

    def initialize(success, message, api_response, options = {})
      @success, @message, @api_response = success, message, api_response
      @test = options[:test] || false
      @error_name = options[:error_name]
      @authorization = options[:authorization]
    end

    def success?
      @success
    end

    def test?
      @test
    end

    def to_s
      message
    end

    # To ensure solidus can process the payment
    def avs_result
      {}
    end

    # To ensure solidus can process the payment
    def cvv_result
      nil
    end
  end
end
