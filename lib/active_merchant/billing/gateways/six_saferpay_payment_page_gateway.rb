require 'activemerchant'
require 'six_saferpay'

module ActiveMerchant
  module Billing
    module Gateways
      class SixSaferpayPaymentPageGateway < Gateway
        # * <tt>purchase(money, credit_card, options = {})</tt>
        # * <tt>authorize(money, credit_card, options = {})</tt>
        # * <tt>capture(money, authorization, options = {})</tt>
        # * <tt>void(identification, options = {})</tt>
        # * <tt>credit(money, identification, options = {})</tt>
        # * <tt>refund(money, identification, options = {})</tt>
        # * <tt>verify(credit_card, options = {})</tt>

        # undef .supports? so that it is delegated to the payment method
        # see https://github.com/solidusio/solidus/blob/master/core/app/models/spree/payment_method/credit_card.rb#L20
        class << self
          undef_method :supports?
        end

        attr_reader :saferpay_client

        def initialize(options = {})
          SixSaferpay.configure do |config|
            config.customer_id = '246353'#'245294'#ENV.fetch('SIX_SAFERPAY_CUSTOMER_ID')
            config.terminal_id = '17942698'#'17925560'#ENV.fetch('SIX_SAFERPAY_TERMINAL_ID')
            config.username = 'API_246353_14688433'#'API_245294_08700063'#ENV.fetch('SIX_SAFERPAY_USERNAME')
            config.password = 'JsonApiPwd1_H7wv6aDA'#'mei4Xoozle4doi0A'#ENV.fetch('SIX_SAFERPAY_PASSWORD')
            config.success_url = 'http://localhost:3001/solidus_six_saferpay/payment_page/success'#ENV.fetch('SIX_SAFERPAY_FAIL_URL')
            config.fail_url = 'http://localhost:3001/solidus_six_saferpay/payment_page/fail'#ENV.fetch('SIX_SAFERPAY_FAIL_URL')
            config.base_url = 'https://test.saferpay.com/api/'#ENV.fetch('SIX_SAFERPAY_BASE_URL')
            config.css_url = ''#ENV.fetch('SIX_SAFERPAY_CSS_URL')
          end
        end

        # For the given order, initialize a new PaymentPage
        # @param [Spree::Order] order The order for which the payment is initialized
        # @return [ActiveMerchant::Billing::Response]
        def initialize_payment_page(order)

          payment = SixSaferpay::Payment.new(
            amount: SixSaferpay::Amount.new(value: (order.total * 100).to_i, currency_code: order.currency),
            order_id: order.number,
            description: order.number
          )


          payment_page_initialize = SixSaferpay::SixPaymentPage::Initialize.new(payment: payment)
          saferpay_initialize_response = SixSaferpay::Client.post(payment_page_initialize)

          ActiveMerchant::Billing::Response.new(
            true, 
            "Saferpay Payment Page initialized successfully, token: #{saferpay_initialize_response.token}",
            saferpay_initialize_response.to_h.with_indifferent_access,
          )

          # TODO: update error handler according to SixSaferpay gem Error classes
        rescue StandardError => e
          SolidusSixSaferpay::ErrorHandler.handle(e, level: :error)

          # TODO: Find out if we need to pass options
          ActiveMerchant::Billing::Response.new(
            false, 
            "Saferpay Payment Page could not be initialized",
            saferpay_initialize_response.to_h,
          )
        end

        def assert(token)
          payment_page_assert = SixSaferpay::SixPaymentPage::Assert.new(token: token)

          saferpay_assert_response = SixSaferpay::Client.post(payment_page_assert)

          ActiveMerchant::Billing::Response.new(
            true,
            "Saferpay Payment Page assert response: #{saferpay_assert_response}",
            saferpay_assert_response.to_h
          )
        rescue StandardError => e
          require 'pry'; binding.pry
          SolidusSixSaferpay::ErrorHandler.handle(e, level: :error)

          ActiveMerchant::Billing::Response.new(
            false,
            "Saferpay Payment Page assert could not be requested",
            saferpay_assert_response.to_h.with_indifferent_access
          )
        end

        # Defined by solidus to combine authorize + capture
        def purchase(amount, payment_source, options = {})
          payment = options[:originator]
          capture(amount, payment.response_code, options)

        rescue StandardError => e
          require 'pry'; binding.pry

          ActiveMerchant::Billing::Response.new(
            false,
            "Transaction can not be captured, error in payment (originator)",
            options
          )
        end

        # Finalize an authorized payment
        def capture(amount, transaction_id, options={})
          transaction_reference = SixSaferpay::TransactionReference.new(transaction_id: transaction_id)
          payment_page_capture = SixSaferpay::SixTransaction::Capture.new(transaction_reference: transaction_reference)

          saferpay_capture_response = SixSaferpay::Client.post(payment_page_capture)

          ActiveMerchant::Billing::Response.new(
            true,
            "Saferpay Payment Page capture response: #{saferpay_capture_response}",
            saferpay_capture_response.to_h.with_indifferent_access
          )
        rescue StandardError => e
          SolidusSixSaferpay::ErrorHandler.handle(e, level: :error)

          ActiveMerchant::Billing::Response.new(
            false,
            "Saferpay Payment Page capture failed",
            saferpay_capture_response.to_h
          )
        end

        # Release authorized uncaptured payments
        def void(identification, options = {})
          # TODO:
          # - ???
        end


        # aliased to support solidus code
        def credit(amount, transaction_id, options={})
          refund(amount, transaction_id, options)
        end

        # Refund previously captured payment
        def refund(amount, transaction_id, options={})
          # TODO:
          # - post request
          # - parse response
          # - handle errors
          # - ???
          # - return AM response
        end

        def verify(credit_card_payment_source, options = {})
          raise "#verify is not supported for Six Saferpay Payment Page"
        end

        # Allocate the reqested amount for a payment
        def authorize(amount, credit_card_payment_source, options = {})
          raise "#authorize is not supported for Six Saferpay Payment Page"
        end
      end
    end
  end
end
