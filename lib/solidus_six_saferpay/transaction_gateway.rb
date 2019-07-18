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

    # TODO
    def inquire(payment_source, options = {})
      transaction_inquire = SixSaferpay::SixTransaction::Inquire.new(transaction_reference: payment_source.transaction_id)
      inquire_response = SixSaferpay::Client.post(transaction_inquire)

      respose(
        true,
        "Saferpay Transaction inquire response: #{inquire_response.to_h}",
        inquire_response
      )
    rescue SixSaferpay::Error => e
      handle_error(e, inquire_response)
    end

    def authorize(amount, payment_source, options = {})
      transaction_authorize = SixSaferpay::SixTransaction::Authorize.new(token: payment_source.token)
      authorize_response = SixSaferpay::Client.post(transaction_authorize)

      response(
        true,
        "Saferpay Transaction authorize response: #{authorize_response.to_h}",
        authorize_response
      )
    rescue SixSaferpay::Error => e
      handle_error(e, authorize_response)
    rescue InvalidSaferpayPayment => e
      handle_error(e, authorize_response)
    end

    private

    def interface_initialize_object(order, payment_method)
      SixSaferpay::SixTransaction::Initialize.new(interface_initialize_params(order, payment_method))
    end
  end
end
