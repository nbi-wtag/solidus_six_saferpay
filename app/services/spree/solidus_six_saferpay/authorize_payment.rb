module Spree
  module SolidusSixSaferpay
    class AuthorizePayment
      attr_reader :payment_source, :order, :success

      def self.call(payment_source)
        new(payment_source).call
      end

      def initialize(payment_source)
        @payment_source = payment_source
        @order = payment_source.order
      end

      def call
        authorization = gateway_class.new.authorize(order.total, payment_source)

        if authorization.success?
          if ensure_valid_payment(payment_source, authorization.api_response)

            payment_source.update_attributes!(payment_source_attributes(authorization.api_response))
            void_and_invalidate_old_solidus_payments
            create_solidus_payment
            @success = true
          else
            # TODO: Handle correctly
            raise "INVALID PAYMENT"
          end
        end

        self
      end

      def success?
        @success
      end

      private

      def gateway_class
        raise NotImplementedError, "Must be implemented in AssertPaymentPage or AuthorizeTransaction"
      end

      def create_solidus_payment
        payment_source.create_payment!
      end

      def void_and_invalidate_old_solidus_payments
        order.payments.valid.each do |payment|
          puts "INVALIDATE: #{payment.id}"
        end
      end

      def ensure_valid_payment(payment_source, saferpay_response)
        order = payment_source.order
        saferpay_transaction = saferpay_response.transaction
        ensure_authorized(saferpay_transaction)
        ensure_correct_order(order, saferpay_transaction)
        ensure_equal_amount(order, saferpay_transaction)

        true
      end

      def ensure_authorized(saferpay_transaction)
        if saferpay_transaction.status != "AUTHORIZED"
          raise InvalidSaferpayPayment.new(details: "Status should be 'AUTHORIZED', is: '#{saferpay_response.transaction.status}'")
        end
      end

      def ensure_correct_order(order, saferpay_transaction)
        if order.number != saferpay_transaction.order_id
          raise InvalidSaferpayPayment.new(details: "Order ID should be '#{order.number}', is: '#{saferpay_response.transaction.order_id}'")
        end

        true
      end

      def ensure_equal_amount(order, saferpay_transaction)
        order_amount = Spree::Money.new(order.total, currency: order.currency)

        saferpay_transaction_currency = saferpay_transaction.amount.currency_code
        if order_amount.currency.iso_code != saferpay_transaction_currency
          raise InvalidSaferpayPayment.new(details: "Currency should be '#{order.currency}', is: '#{saferpay_transaction_currency}'")
        end

        saferpay_transaction_cents = saferpay_transaction.amount.value
        if order_amount.cents.to_s != saferpay_transaction_cents
          raise InvalidSaferpayPayment.new(details: "Order total (cents) should be '#{order_amount.cents}', is: '#{saferpay_transaction_cents}'")
        end

        true
      end
    end
  end
end
