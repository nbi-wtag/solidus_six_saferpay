module SolidusSixSaferpay
  class TransactionGateway < Gateway

    def authorize(amount, payment_source, options = {})
      # TODO: 
      raise "TODO"
      transaction_authorize = SixSaferpay::SixTransaction::Authorize.new()
      authorize_response = SixSaferpay::Client.post(transaction_authorize)
    end

    private

    def interface_initialize_object(order, payment_method)
      SixSaferpay::SixTransaction::Initialize.new(interface_initialize_params(order, payment_method))
    end
  end
end
