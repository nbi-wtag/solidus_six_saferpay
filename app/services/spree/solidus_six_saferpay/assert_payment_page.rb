module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class AssertPaymentPage < HandleSuccessfulPaymentInitialize
      attr_reader :payment_source, :success

      def self.call(payment_source)
        new(payment_source).call
      end

      def initialize(payment_source)
        @payment_source = payment_source
      end

      private

      def gateway_class
        SolidusSixSaferpay::PaymentPageGateway
      end

      def gateway_method
        :assert
      end

      def gateway_arguments
        [payment_source.order.total, payment_source]
      end

      # TODO: Extract
      def update_payment_source!(payment_source, saferpay_response)
        payment_source.update_attributes!(attributes)
      end

      def payment_source_attributes(saferpay_response)
        attributes = {}
        attributes[:transaction_id] = saferpay_response.transaction.id
        attributes[:transaction_status] = saferpay_response.transaction.status
        attributes[:transaction_date] = DateTime.parse(saferpay_response.transaction.date)
        attributes[:six_transaction_reference] = saferpay_response.transaction.six_transaction_reference
        attributes[:display_text] = saferpay_response.payment_means.display_text

        if card = saferpay_response.payment_means.card
          attributes
          attributes[:masked_number] = card.masked_number,
            attributes[:expiration_year] = card.exp_year,
            attributes[:expiration_month] = card.exp_month
        end
      end
    end
  end
end

