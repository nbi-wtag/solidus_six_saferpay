module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class InquirePayment
      attr_reader :payment_source, :order, :success, :user_message

      def self.call(payment_source)
        new(payment_source).call
      end

      def initialize(payment_source)
        @payment_source = payment_source
        @order = payment_source.order
      end

      def call
        inquiry = gateway.inquire(payment_source)

        if inquiry.success?
          payment_source.update_attributes(response_hash: inquiry.api_response.to_h)
        else
          @user_message = I18n.t("six_saferpay.error_names.#{inquiry.error_name}")
        end
        
        @success = true

        self
      end

      def success?
        @success
      end

      private

      def gateway
        raise NotImplementedError, "Must be implemented in AssertPaymentPage or AuthorizeTransaction with UsePaymentPageGateway or UseTransactionGateway"
      end
    end
  end
end
