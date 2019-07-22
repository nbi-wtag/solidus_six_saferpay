module Spree
  class PaymentMethod::SaferpayPaymentPage < PaymentMethod::SaferpayPaymentMethod


    def gateway_class
      ::SolidusSixSaferpay::PaymentPageGateway
    end

    def init_path
      url_helpers.solidus_six_saferpay_payment_page_init_path
    end
  end
end
