module Spree
  class PaymentMethod::SaferpayTransaction < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ActiveMerchant::Billing::Gateways::SixSaferpayTransactionGateway
    end

    def partial_name
      :saferpay_transaction
    end
  end
end
