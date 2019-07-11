module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class AssertPaymentPage < AuthorizePayment

      private

      def gateway_class
        ::SolidusSixSaferpay::PaymentPageGateway
      end

      def payment_source_attributes(saferpay_response)
        payment_means = saferpay_response.payment_means
        brand = payment_means.brand
        card = payment_means.card
        attributes = {}
        attributes[:transaction_id] = saferpay_response.transaction.id
        attributes[:transaction_status] = saferpay_response.transaction.status
        attributes[:transaction_date] = DateTime.parse(saferpay_response.transaction.date)
        attributes[:six_transaction_reference] = saferpay_response.transaction.six_transaction_reference
        attributes[:display_text] = saferpay_response.payment_means.display_text
        # TODO: Add Attribute to SixSaferpayPayment
        # attributes[:icon_name] = brand.payment_method.downcase

        if card
          attributes[:masked_number] = card.masked_number
          attributes[:expiration_year] = card.exp_year
          attributes[:expiration_month] = card.exp_month
        end

        attributes[:response_hash] = saferpay_response.to_h
        attributes
      end

    end
  end
end

