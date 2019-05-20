module Spree
  class PaymentMethod::SaferpayTransaction < PaymentMethod::CreditCard

    def gateway_class
      ActiveMerchant::Billing::Gateways::SixSaferpayTransactionGateway
    end

    def payment_source_class
      Spree::CreditCard
    end

    def profiles_supported?
      false
    end

    def partial_name
      :saferpay_transaction
    end

    # We want to automatically capture the payment when the order is completed
    def auto_capture
      true
    end
  end
end
