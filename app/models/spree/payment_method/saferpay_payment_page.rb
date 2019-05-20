module Spree
  class PaymentMethod::SaferpayPaymentPage < PaymentMethod::CreditCard

    preference :as_iframe, :boolean, default: false

    def gateway_class
      ActiveMerchant::Billing::Gateways::SixSaferpayPaymentPageGateway
    end

    def payment_source_class
      Spree::CreditCard
    end

    def profiles_supported?
      false
    end

    def partial_name
      :saferpay_payment_page
    end

    # We want to automatically capture the payment when the order is completed
    def auto_capture
      true
    end
  end
end
