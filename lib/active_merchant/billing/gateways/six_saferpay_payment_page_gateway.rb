module ActiveMerchant
  module Billing
    module Gateways
      class SixSaferpayPaymentPageGateway < SixSaferpayGateway

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

        private

        def interface_initialize_object(order, payment_method)
          SixSaferpay::SixPaymentPage::Initialize.new(interface_initialize_params(order, payment_method))
        end
      end
    end
  end
end
