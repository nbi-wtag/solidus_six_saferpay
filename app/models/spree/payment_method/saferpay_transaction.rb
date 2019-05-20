module Spree
  # TODO: THIS IS WIP, ADD FUNCTIONALITY
  class PaymentMethod::SaferpayTransaction < PaymentMethod::CreditCard

    # preference :as_iframe, :boolean, default: false

    def gateway_class
      ActiveMerchant::Billing::Gateways::SixSaferpayTransactionGateway
    end

    # Handled by CreditCard
    # def payment_source_class
    #   Spree::CreditCard
    # end

    # def profiles_supported?
    #   false
    # end

    # def partial_name
    #   :saferpay_payment_page
    # end

    # # NOTE: This will be handled by the SixSaferpayGateway
    # # def authorize(cents, source, gateway_options)
    # #   raise "Authorize action is not supported for Saferpay Payment Page because the Authorization happens automatically when submitting the Saferpay Payment Page.\nYou may be looking for the Saferpay Transaction payment method."
    # # end

    # # NOTE: This will be handled by the SixSaferpayGateway
    # # def purchase(cents, source, gateway_options)
    # #   params = {}
    # #   options = {}

    # #   payment = gateway_options[:originator]
    # #   if capture_payment(payment.number)
    # #     ActiveMerchant::Billing::Response.new(true, "Capture Successful", params, options)
    # #   else
    # #     ActiveMerchant::Billing::Response.new(false, "Capture Error", params, options)
    # #   end
    # # end

    # # We want to automatically capture the payment when the order is completed
    # def auto_capture
    #   true
    # end


    # private

    # def capture_payment(transaction_id)
    #   SolidusSixPayments::CaptureSaferpayPaymentPage.call(transaction_id)
    # end
  end
end
