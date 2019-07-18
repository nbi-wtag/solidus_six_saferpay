module SolidusSixSaferpay
  class PaymentPageGateway < Gateway

    def initialize(options = {})
      super(
        options.merge(
          success_url: url_helpers.solidus_six_saferpay_payment_page_success_url,
          fail_url: url_helpers.solidus_six_saferpay_payment_page_fail_url
        )
      )
    end

    def inquire(saferpay_payment, options = {})
      inquire_response = perform_assert_request(saferpay_payment, options)

      response(
        true,
        "Saferpay Payment Page assert response: #{assert_response.to_h}",
        inquire_response
      )
    rescue SixSaferpay::Error => e
      handle_error(e, inquire_response)
    end

    def authorize(_amount, saferpay_payment, options = {})
      assert(saferpay_payment, options)
    end

    def assert(saferpay_payment, options = {})
      assert_response = perform_assert_request(saferpay_payment, options)

      response(
        true,
        "Saferpay Payment Page assert response: #{assert_response.to_h}",
        assert_response
      )
    rescue SixSaferpay::Error => e
      # TODO: MAYBE BETTER HANDLING FOR FAILED TRANSACTIONS?
      handle_error(e, assert_response)
    end

    private

    def perform_assert_request(saferpay_payment, options = {})
      payment_page_assert = SixSaferpay::SixPaymentPage::Assert.new(token: saferpay_payment.token)
      SixSaferpay::Client.post(payment_page_assert)
    end

    def interface_initialize_object(order, payment_method)
      SixSaferpay::SixPaymentPage::Initialize.new(interface_initialize_params(order, payment_method))
    end
  end
end
