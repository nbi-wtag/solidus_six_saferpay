module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    # TODO: Ensure that we invalidate old payments (they don't get invalidated when already processing)
    class InitializePayment

      attr_reader :order, :payment_method, :redirect_url

      def self.call(order, payment_method)
        new(order, payment_method).call
      end

      def initialize(order, payment_method)
        @order = order
        @payment_method = payment_method
      end

      def call
        checkout_initialize = gateway.initialize_checkout(order, payment_method)

        if checkout_initialize.success?
          saferpay_payment = build_saferpay_payment(checkout_initialize.api_response)
          @redirect_url = saferpay_payment.redirect_url
          @success = saferpay_payment.save!
        end

        self
      end

      def build_saferpay_payment(initialize_response)
        Spree::SixSaferpayPayment.new(saferpay_payment_attributes(initialize_response))
      end

      def success?
        @success
      end

      private

      def gateway
        raise NotImplementedError, "Must be implemented in InitializePaymentPage or InitializeTransaction by including UsePaymentPageGateway or UseTransactionGateway"
      end

      def saferpay_payment_attributes(initialize_response)
        {
          order: order,
          payment_method: payment_method,
          token: initialize_response.token,
          expiration: DateTime.parse(initialize_response.expiration),
          response_hash: initialize_response.to_h
        }
      end
    end
  end
end
