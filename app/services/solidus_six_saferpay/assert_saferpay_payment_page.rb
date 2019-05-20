module SolidusSixSaferpay

  # TODO: SPEC
  class AssertSaferpayPaymentPage

    attr_reader :saferpay_payment, :token, :order, :success

    def self.call(saferpay_payment)
      new(saferpay_payment).call
    end

    def initialize(saferpay_payment)
      @saferpay_payment = saferpay_payment
      @token = saferpay_payment.token
      @order = saferpay_payment.order
    end

    def call
      payment_page_assert = ActiveMerchant::Billing::Gateways::SixSaferpayPaymentPageGateway.new.assert(token)

      if payment_page_assert.success?
        payment_attributes = extract_payment_attributes(payment_page_assert.params)

        payment = Spree::PaymentCreate.new(order, payment_attributes).build

        if payment.save!
          @success = true
        end
      else
        # TODO: CANCEL PAYMENT
        raise "PaymentPageAssert not successful"
      end

      self
    end

    def success?
      success || false
    end

    private

    def extract_payment_attributes(asserted_payment)
      transaction = asserted_payment[:Transaction]
      payment_means = asserted_payment[:PaymentMeans]
      payer = asserted_payment[:Payer]
      liability = asserted_payment[:Liability]
      dcc = asserted_payment[:Dcc]

      payment_attributes = {
        amount: normalized_amount(transaction[:Amount][:Value]),
        response_code: transaction[:Id], 
        payment_method_id: Spree::PaymentMethod.find_by(type: 'Spree::PaymentMethod::SaferpayPaymentPage').id,
        source_attributes: {
          imported: true, # necessary because we don't want to validate CVV
          number: payment_means[:DisplayText],
          month: payment_means[:Card][:ExpMonth],
          year: payment_means[:Card][:ExpMonth],
          cc_type: payment_means[:Brand][:PaymentMethod],
          name: payment_means[:Card][:HolderName],
        }
      }
    end

    def normalized_amount(cents_string)
      cents = cents_string.to_i

      amount, remainder = cents.divmod(100)
      if !remainder.zero?
        raise "Remainder not zero, #{cents} can not be normalized"
      end

      amount
    end
  end
end
