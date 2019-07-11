module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    # TODO: Ensure that we invalidate old payments (they don't get invalidated when already processing)
    class InitializeCheckout

      attr_reader :order, :payment_method, :redirect_url

      def self.call(order, payment_method)
        new(order, payment_method).call
      end

      def initialize(order, payment_method)
        @order = order
        @payment_method = payment_method
      end

      def call
        checkout_initialize = gateway_class.new.initialize_checkout(order, payment_method)

        if checkout_initialize.success?
          payment_source = build_payment_source(checkout_initialize.api_response)
          @redirect_url = payment_source.redirect_url
          @success = payment_source.save!
        end

        self
      end

      def build_payment_source(initialize_response)
        Spree::SixSaferpayPayment.new(payment_source_attributes(initialize_response))
      end

      def success?
        @success
      end

      private

      def gateway_class
        raise NotImplementedError, "Must be implemented in InitializePaymentPage or InitializeTransaction"
      end

      def payment_source_attributes(initialize_response)
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
