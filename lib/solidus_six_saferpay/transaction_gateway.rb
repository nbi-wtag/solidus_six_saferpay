module SolidusSixSaferpay
  class TransactionGateway < Gateway

    def authorize(amount, payment_source, options = {})
      # TODO: 
      raise "TODO"
    end

    private

    def interface_initialize_object(order, payment_method)
      SixSaferpay::SixTransaction::Initialize.new(interface_initialize_params(order, payment_method))
    end
  end
end
