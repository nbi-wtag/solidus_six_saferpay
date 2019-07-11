module SolidusSixSaferpay
  class TransactionGateway < Gateway

    def authorize(amount, payment_source, options = {})
      assert(amount, payment_source, options)
    end

    def assert(amount, payment_source, options = {})
      payment_page_assert = SixSaferpay::SixPaymentPage::Assert.new(token: payment_source.token)
      assert_response = SixSaferpay::Client.post(payment_page_assert)

      response(
        success: true,
        message: "Saferpay Payment Page assert response: #{assert_response}",
        api_response: assert_response
      )
    rescue SixSaferpay::Error => e
      handle_error(e, assert_response)
    rescue InvalidSaferpayPayment => e
      handle_error(e, assert_response)
    end

    private

    def interface_initialize_object(order, payment_method)
      SixSaferpay::SixTransaction::Initialize.new(interface_initialize_params(order, payment_method))
    end
  end
end
