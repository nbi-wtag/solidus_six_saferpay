module Spree
  class PaymentMethod::SaferpayPaymentPage < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ActiveMerchant::Billing::Gateways::SixSaferpayPaymentPageGateway
    end

    def partial_name
      :saferpay_payment_page
    end
  end
end
