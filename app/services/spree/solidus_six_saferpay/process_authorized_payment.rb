module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class ProcessAuthorizedPayment

      attr_reader :saferpay_payment, :order, :success, :user_message

      def self.call(saferpay_payment)
        new(saferpay_payment).call
      end

      def initialize(saferpay_payment)
        @saferpay_payment = saferpay_payment
        @order = saferpay_payment.order
      end

      def call
        validate_payment!

        # SUCCESS!

        void_old_solidus_payments
        saferpay_payment.create_solidus_payment!
        @success = true

        self

      rescue InvalidSaferpayPayment => e
        # TODO: Check if user message is appropriate!
        cancel_saferpay_payment
        @user_message = e.full_message
        @success = false

        self
      end

      def success?
        @success
      end

      private

      def gateway
        raise NotImplementedError, "Must be implemented in ProcessPaymentPagePayment or ProcessTransactionPayment"
      end

      # Cancels only the saferpay payment without affecting solidus
      def cancel_saferpay_payment
        if transaction_id = saferpay_payment.transaction_id
          gateway.void(transaction_id)
        end
      end

      # Cancels the solidus payments which automatically cancels the saferpay
      # payments
      def void_old_solidus_payments
        order.payments.valid.where.not(state: :void).each do |payment|
          # void or create refund
          payment.cancel!
        end
      end

      def validate_payment!
        validate_liability_shift

        saferpay_transaction = saferpay_payment.transaction

        validate_payment_state(saferpay_transaction)
        validate_order_reference(saferpay_transaction)
        validate_order_amount(saferpay_transaction)

        true
      end

      def validate_liability_shift
        if liability_shift_required? && !liability_shifted?
          raise InvalidSaferpayPayment.new(details: "Liability Shift not granted for payment")
        end
      end

      def liability_shift_required?
        saferpay_payment.payment_method.preferred_liability_shift_required
      end

      def liability_shifted?
        saferpay_payment.liability.liability_shift
      end

      def validate_payment_state(saferpay_transaction)
        if saferpay_transaction.status != "AUTHORIZED"
          raise InvalidSaferpayPayment.new(details: "Status should be 'AUTHORIZED', is: '#{saferpay_response.transaction.status}'")
        end
      end

      def validate_order_reference(saferpay_transaction)
        if order.number != saferpay_transaction.order_id
          raise InvalidSaferpayPayment.new(details: "Order ID should be '#{order.number}', is: '#{saferpay_response.transaction.order_id}'")
        end

        true
      end

      def validate_order_amount(saferpay_transaction)
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

      class InvalidSaferpayPayment < StandardError
        def initialize(message: "Saferpay Payment is invalid", details: "")
          super("#{message}: #{details}".strip)
        end

        def full_message
          message
        end
      end
    end
  end
end
