module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class HandleSuccessfulPaymentInitialize

      attr_reader :payment_source, :success

      def self.call(payment_source)
        new(payment_source).call
      end

      def initialize(payment_source)
        @payment_source = payment_source
      end

      def call
        # TODO: HERE!!!!
        handle_successful_payment = gateway_class.new.send(gateway_method, *gateway_arguments)

        if handle_successful_payment.success?
          if ensure_valid_payment(payment_source, handle_successful_payment.params.with_indifferent_access)
            require 'pry'; binding.pry
            payment_source.update_attributes!(payment_source_attributes(handle_successful_payment))
            invalidate_old_solidus_payments
            payment = create_solidus_payment
            @success = true
          else
            # TODO
            raise "INVALID PAYMENT!"

          end
        end

        self
      end

      private

      def create_solidus_payment
        payment_source.create_payment!
      end

      def invalidate_old_solidus_payments
        puts "NEW PAYMENT: #{current_payment.id}"
        payment_source.order.payments.valid.each do |payment|
          puts "INVALIDATE: #{payment.id}"
        end
      end

      def ensure_valid_payment(payment_source, saferpay_response_params)
        order = payment_source.order
        saferpay_transaction = saferpay_response_params[:transaction]
        ensure_authorized(saferpay_transaction)
        ensure_correct_order(order, saferpay_transaction)
        ensure_equal_amount(order, saferpay_transaction)

        true
      end

      def ensure_authorized(saferpay_transaction)
        require 'pry'; binding.pry
        if saferpay_transaction[:status] != "AUTHORIZED"
          raise InvalidSaferpayPayment.new(details: "Status should be 'AUTHORIZED', is: '#{saferpay_response.transaction.status}'")
        end
      end

      def ensure_correct_order(order, saferpay_transaction)
        if order.number != saferpay_transaction[:order_id]
          raise InvalidSaferpayPayment.new(details: "Order ID should be '#{order.number}', is: '#{saferpay_response.transaction.order_id}'")
        end

        true
      end

      def ensure_equal_amount(order, saferpay_transaction)
        order_amount = Spree::Money.new(order.total, currency: order.currency)

        saferpay_transaction_currency = saferpay_transaction[:amount][:currency_code]
        if order_amount.currency.iso_code != saferpay_transaction_currency
          raise InvalidSaferpayPayment.new(details: "Currency should be '#{order.currency}', is: '#{saferpay_transaction_currency}'")
        end
        saferpay_transaction_cents = saferpay_transaction[:amount][:value]
        if order_amount.cents.to_s != saferpay_transaction_cents
          raise InvalidSaferpayPayment.new(details: "Order total (cents) should be '#{order_amount.cents}', is: '#{saferpay_transaction_cents}'")
        end

        true
      end
    end
  end
end
