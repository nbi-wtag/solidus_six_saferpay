module ActiveMerchant
  module Billing
    module Gateways
      class SixSaferpayPaymentPageGateway < SixSaferpayGateway

        def initialize_payment_page(order, payment_method)
          amount = Spree::Money.new(order.total, currency: order.currency)
          payment = SixSaferpay::Payment.new(
            amount: SixSaferpay::Amount.new(value: amount.cents, currency_code: amount.currency.iso_code),
            order_id: order.number,
            description: order.number
          )
          six_payment_methods = payment_method.enabled_payment_methods
          params = { payment: payment }
          params.merge!(payment_methods: six_payment_methods) unless six_payment_methods.blank?

          payment_page_initialize = SixSaferpay::SixPaymentPage::Initialize.new(params)
          initialize_response = SixSaferpay::Client.post(payment_page_initialize)

          response(
            success: true,
            message: "Saferpay Payment Page initialized successfully, token: #{initialize_response.token}",
            params: initialize_response.to_h.with_indifferent_access,
          )
        rescue SixSaferpay::Error => e
          handle_error(e, initialize_response)
        end

        def authorize(amount, payment_source, options = {})
          assert(amount, payment_source, options)
        end

        def assert(amount, payment_source, options = {})
          payment_page_assert = SixSaferpay::SixPaymentPage::Assert.new(token: payment_source.token)
          assert_response = SixSaferpay::Client.post(payment_page_assert)


          ensure_valid_payment(payment_source, assert_response)

          update_payment_source!(payment_source, assert_response)

          response(
            success: true,
            message: "Saferpay Payment Page assert response: #{assert_response}",
            params: assert_response.to_h
          )
        rescue SixSaferpay::Error => e
          handle_error(e, assert_response)
        rescue InvalidSaferpayPayment => e
          handle_error(e, assert_response)
        end

        # # TODO
        # Release authorized uncaptured payments
        def void(identification, options = {})
        end


        # aliased to support solidus code
        def credit(amount, transaction_id, options={})
          refund(amount, transaction_id, options)
        end

        # TODO
        # Refund previously captured payment
        def refund(amount, transaction_id, options={})
          # TODO:
          # - post request
          # - parse response
          # - handle errors
          # - ???
          # - return AM response
        end
      end
    end
  end
end
