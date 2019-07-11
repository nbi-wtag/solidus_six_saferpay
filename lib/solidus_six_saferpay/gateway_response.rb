module SolidusSixSaferpay

  class GatewayResponse
    attr_reader :api_response, :message, :test, :error_code, :authorization

    def success?
      @success
    end

    def test?
      @test
    end

    def initialize(success, message, api_response, options = {})
      @success, @message, @api_response = success, message, api_response
      @test = options[:test] || false
      @error_code = options[:error_code]
      @authorization = options[:authorization]
    end
  end

end
