require 'activemerchant'
require 'six_saferpay'

module ActiveMerchant
  module Billing
    module Gateways
      class SixSaferpayGateway < Gateway
        class InvalidSaferpayPayment < StandardError
          def initialize(message: "Saferpay Payment is invalid", details: "")
            super("#{message}: #{details}".strip)
          end

          def full_message
            message
          end
        end

        # undef .supports? so that it is delegated to the payment method
        # see https://github.com/solidusio/solidus/blob/master/core/app/models/spree/payment_method/credit_card.rb#L20
        class << self
          undef_method :supports?
        end

        def initialize(options = {})
          # TODO: extract this to initializer
          SixSaferpay.configure do |config|
            config.customer_id = options.fetch(:customer_id, ENV.fetch('SIX_SAFERPAY_CUSTOMER_ID'))
            config.terminal_id = options.fetch(:terminal_id, ENV.fetch('SIX_SAFERPAY_TERMINAL_ID'))
            config.username = options.fetch(:username, ENV.fetch('SIX_SAFERPAY_USERNAME'))
            config.password = options.fetch(:password, ENV.fetch('SIX_SAFERPAY_PASSWORD'))
            config.success_url = options.fetch(:success_url, ENV.fetch('SIX_SAFERPAY_SUCCESS_URL'))
            config.fail_url = options.fetch(:fail_url, ENV.fetch('SIX_SAFERPAY_FAIL_URL'))
            config.base_url = options.fetch(:base_url, ENV.fetch('SIX_SAFERPAY_BASE_URL'))
            config.css_url = ''
          end
        end

        def purchase(amount, payment_source, options = {})
          auth_response = authorize(amount, payment_source, options)
          if auth_response.success?
            capture(amount, payment_source.transaction_id, options)
          else
            auth_response
          end
        end


        def capture(amount, transaction_id, options={})
          transaction_reference = SixSaferpay::TransactionReference.new(transaction_id: transaction_id)
          payment_page_capture = SixSaferpay::SixTransaction::Capture.new(transaction_reference: transaction_reference)

          capture_response = SixSaferpay::Client.post(payment_page_capture)

          response(
            success: true,
            message: "Saferpay Payment Page capture response: #{capture_response}",
            params: capture_response.to_h,
            options: { authorization: capture_response.capture_id }
          )
        rescue SixSaferpay::Error => e
          handle_error(e, capture_response)
        end

        private

        def ensure_valid_payment(payment_source, saferpay_response)
          order = payment_source.order
          ensure_authorized(saferpay_response)
          ensure_correct_order(order, saferpay_response)
          ensure_equal_amount(order, saferpay_response)

          true
        end

        def ensure_authorized(saferpay_response)
          if saferpay_response.transaction.status != "AUTHORIZED"
            raise InvalidSaferpayPayment.new(details: "Status should be 'AUTHORIZED', is: '#{saferpay_response.transaction.status}'")
          end
        end

        def ensure_correct_order(order, saferpay_response)
          if order.number != saferpay_response.transaction.order_id
            raise InvalidSaferpayPayment.new(details: "Order ID should be '#{order.number}', is: '#{saferpay_response.transaction.order_id}'")
          end

          true
        end

        def ensure_equal_amount(order, saferpay_response)
          order_amount = Spree::Money.new(order.total, currency: order.currency)
          saferpay_transaction = saferpay_response.transaction

          if order_amount.currency.iso_code != saferpay_transaction.amount.currency_code
            raise InvalidSaferpayPayment.new(details: "Currency should be '#{order.currency}', is: '#{saferpay_transaction.amount.currency_code}'")
          end
          if order_amount.cents.to_s != saferpay_transaction.amount.value.to_s
            raise InvalidSaferpayPayment.new(details: "Order total (cents) should be '#{order_amount.cents}', is: '#{saferpay_transaction.amount.value}'")
          end

          true
        end

        def update_payment_source!(payment_source, saferpay_response)
          payment_source.update_attributes!(
            transaction_id: saferpay_response.transaction.id,
            transaction_status: saferpay_response.transaction.status,
            transaction_date: DateTime.parse(saferpay_response.transaction.date),
            six_transaction_reference: saferpay_response.transaction.six_transaction_reference,
            display_text: saferpay_response.payment_means.display_text,
            masked_number: saferpay_response.payment_means.card.masked_number,
            expiration_year: saferpay_response.payment_means.card.exp_year,
            expiration_month: saferpay_response.payment_means.card.exp_month
          )
        end

        def handle_error(error, response)
          SolidusSixSaferpay::ErrorHandler.handle(error, level: :error)

          response(
            success: false,
            message: error.full_message,
            params: response.to_h
          )
        end

        def response(success:, message:, params: {}, options: {})
          ActiveMerchant::Billing::Response.new(success, message, params, options)
        end
      end
    end
  end
end
