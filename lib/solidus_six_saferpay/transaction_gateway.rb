module SolidusSixSaferpay
  class TransactionGateway < Gateway

    def initialize(options = {})
      super(
        options.merge(
          success_url: url_helpers.solidus_six_saferpay_transaction_success_url,
          fail_url: url_helpers.solidus_six_saferpay_transaction_fail_url
        )
      )
    end

    def inquire(saferpay_payment, options = {})
      transaction_inquire = SixSaferpay::SixTransaction::Inquire.new(transaction_reference: saferpay_payment.transaction_id)
      inquire_response = SixSaferpay::Client.post(transaction_inquire)

      respose(
        true,
        "Saferpay Transaction inquire response: #{inquire_response.to_h}",
        inquire_response
      )
    rescue SixSaferpay::Error => e
      handle_error(e, inquire_response)
    end

    def authorize(amount, saferpay_payment, options = {})
      transaction_authorize = SixSaferpay::SixTransaction::Authorize.new(token: saferpay_payment.token)
      authorize_response = SixSaferpay::Client.post(transaction_authorize)

      response(
        true,
        "Saferpay Transaction authorize response: #{authorize_response.to_h}",
        authorize_response
      )
    rescue SixSaferpay::Error => e
      handle_error(e, authorize_response)
    end

    private

    def interface_initialize_object(order, payment_method)
      SixSaferpay::SixTransaction::Initialize.new(interface_initialize_params(order, payment_method))
    end
  end
end
