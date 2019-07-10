module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class CancelTransaction

      attr_reader :order

      def self.call(order)
        new(order).call
      end

      def initialize(order)
        @order = order
      end

      def call
        @order.payments.valid.each do |payment|
          payment.void_transaction!
        end
      end

      private

      def gateway_class
        ActiveMerchant::Billing::Gateways::SixSaferpayPaymentPageGateway
      end
    end
  end
end
