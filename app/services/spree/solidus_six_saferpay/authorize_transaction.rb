module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class AuthorizeTransaction < AuthorizeCheckout

      private

      def gateway_class
        ::SolidusSixSaferpay::TransactionGateway
      end

      def payment_source_attributes(saferpay_response)
        puts "TODO: CHECK IF THIS MATCHES"
        require 'pry'; binding.pry
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

        attributes
      end

    end
  end
end

