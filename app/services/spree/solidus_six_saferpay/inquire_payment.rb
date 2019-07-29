module Spree
  module SolidusSixSaferpay
    # TODO: This is almost the same as AuthorizePayment
    # TODO: SPEC
    class InquirePayment
      attr_reader :saferpay_payment, :order, :success, :user_message

      def self.call(saferpay_payment)
        new(saferpay_payment).call
      end

      def initialize(saferpay_payment)
        @saferpay_payment = saferpay_payment
        @order = saferpay_payment.order
      end

      # NOTE: This will be successful regardless of the API response.
      # The reason is that the API returns HTTP error codes for failed
      # payments, but the inquiry was still successful
      def call
        inquiry = gateway.inquire(saferpay_payment)

        if inquiry.success?
          saferpay_payment.update_attributes(response_hash: inquiry.api_response.to_h)
        else
          @user_message = I18n.t(inquiry.error_name, scope: [:six_saferpay, :error_names])
        end
        
        @success = true

        self
      end

      def success?
        @success
      end

      def gateway
        raise NotImplementedError, "Must be implemented in AssertPaymentPage or AuthorizeTransaction with UsePaymentPageGateway or UseTransactionGateway"
      end
    end
  end
end
