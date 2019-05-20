module SolidusSixSaferpay

  # TODO: SPEC
  class AssertSaferpayPaymentPage

    attr_reader :saferpay_payment, :token, :order, :payment, :success

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
        asserted_payment = SixSaferpay::SixPaymentPage::AssertResponse.new(payment_page_assert.params.deep_symbolize_keys)
        payment_attributes = extract_payment_attributes(asserted_payment)

        @payment = Spree::PaymentCreate.new(order, payment_attributes).build

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
      transaction = asserted_payment.transaction
      payment_means = asserted_payment.payment_means
      # unused
      #liability = asserted_payment.liability
      #payer = asserted_payment.payer
      #dcc = asserted_payment.dcc

      payment_attributes = {
        amount: normalized_amount(transaction.amount.value),
        response_code: transaction.id,
        # TODO: FIND DYNAMICALLY
        payment_method_id: Spree::PaymentMethod.find_by(type: 'Spree::PaymentMethod::SaferpayPaymentPage').id,
        source_attributes: {
          imported: true, # necessary because we don't want to validate CVV
          number: payment_means.display_text,
          month: payment_means.card.exp_month,
          year: payment_means.card.exp_year,
          cc_type: payment_means.brand.payment_method.downcase, # downcase because SIX returns upcased
          name: payment_means.card.holder_name,
        }
      }
    end

    def normalized_amount(cents_string)
      cents = cents_string.to_i
      cents.to_d / 100
    rescue StandardError => e
      raise "Could not convert string '#{cents_string}' to BigDecimal to store as Payment amount: #{e}"
    end
  end
end
