module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class AuthorizePayment
      attr_reader :payment_source, :order, :success, :user_message

      def self.call(payment_source)
        new(payment_source).call
      end

      def initialize(payment_source)
        @payment_source = payment_source
        @order = payment_source.order
      end

      def call
        authorization = gateway.authorize(order.total, payment_source)

        if !authorization.success?
          raise SolidusSixSaferpay::InvalidSaferpayPayment.new(details: authorization.message)
        end

        # TODO: MAYBE EXTRACT ALL THIS INTO ANOTHER SERVICE SO THAT THIS ONLY PERFORMS AUTHORIZE AND IS REUSABLE FOR INQUIRE?
        handle_liability_shift_requirements(authorization.api_response)

        ensure_valid_payment(authorization.api_response)

        payment_source.update_attributes!(payment_source_attributes(authorization.api_response))
        void_old_solidus_payments
        create_solidus_payment
        @success = true

        self

      rescue SolidusSixSaferpay::InvalidSaferpayPayment => e
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
        raise NotImplementedError, "Must be implemented in AssertPaymentPage or AuthorizeTransaction with UsePaymentPageGateway or UseTransactionGateway"
      end

      def create_solidus_payment
        payment = payment_source.create_payment!
      end

      # Cancels only the saferpay payment without affecting solidus
      def cancel_saferpay_payment
        if transaction_id = payment_source.transaction_id
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

      def handle_liability_shift_requirements(saferpay_response)
        if liability_shift_required? && !liability_shifted?(saferpay_response)
          raise InvalidSaferpayPayment.new(details: "Liability Shift not granted for payment")
        end
      end
    end

    def liability_shift_required?
      payment_source.payment_method.preferred_liability_shift_required
    end

    def liability_shifted?(saferpay_response)
      saferpay_response.liability.liability_shift
    end

    def ensure_valid_payment(saferpay_response)
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
