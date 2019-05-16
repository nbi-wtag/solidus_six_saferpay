module SolidusSixSaferpay
  # TODO: SPEC
  class AssertSaferpayPaymentPage

    attr_reader :payment_page, :token, :order, :success

    def self.call(payment_page)
      new(payment_page).call
    end

    def initialize(payment_page)
      @payment_page = payment_page
      @token = payment_page.token
      @order = payment_page.order
    end

    def call
      payment_page_response = request_payment_page_assert

      payment_attributes = extract_payment_attributes(payment_page_response)

      payment = Spree::PaymentCreate.new(order, payment_attributes).build

      if payment.save!
        update_saferpay_payment_id(payment, payment_attributes[:number])
        @success = true
      end

      self
    end

    def success?
      success || false
    end

    private

    def request_payment_page_assert
      payment_page_assert = SixSaferpay::PaymentPage::Assert.new(token)

      saferpay_response = SixSaferpay::Client.post(payment_page_assert)

      # TODO: Let the Client handle this
      JSON.parse(saferpay_response.body).with_indifferent_access
    end

    def update_saferpay_payment_id(payment, id)
      payment.update_attributes(number: id)
    end

    def extract_payment_attributes(asserted_payment)
      transaction = asserted_payment[:Transaction]
      payment_means = asserted_payment[:PaymentMeans]
      payer = asserted_payment[:Payer]
      liability = asserted_payment[:Liability]
      dcc = asserted_payment[:Dcc]

      payment_attributes = {
        amount: normalized_amount(transaction[:Amount][:Value]),
        number: transaction[:Id], # NOTE: this will be overridden, we need to update it after creating the payment
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
