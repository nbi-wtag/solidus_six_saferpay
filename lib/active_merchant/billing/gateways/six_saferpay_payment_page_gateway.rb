require 'activemerchant'
require 'six_saferpay'

# TODO: PLACEHOLDER UNTIL API IS FINISHED
class InitializeResponse
  attr_reader :token, :expiration, :redirect_url
  def initialize(token:, expiration:, redirect_url:)
    @token = token
    @expiration = expiration
    @redirect_url = redirect_url
  end
end

# TODO PLACEHOLDER UNTIL API IS FINISHED
class AssertResponse
  attr_reader :transaction, :payment_means, :liability

  def initialize(transaction:, payment_means:, liability:)
    @transaction = transaction
    @payment_means = payment_means
    @liability = liability
  end
end

class CaptureResponse
  attr_reader :capture_id, :status, :date

  def initialize(capture_id:, status:, date:)
    @capture_id = capture_id
    @status = status
    @date = date
  end
end

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
            config.success_url = 'http://localhost:3000/solidus_six_saferpay/payment_page/success'#ENV.fetch('SIX_SAFERPAY_FAIL_URL')
            config.fail_url = 'http://localhost:3000/solidus_six_saferpay/payment_page/fail'#ENV.fetch('SIX_SAFERPAY_FAIL_URL')
            config.base_url = 'https://test.saferpay.com/api/'#ENV.fetch('SIX_SAFERPAY_BASE_URL')
            config.css_url = ''#ENV.fetch('SIX_SAFERPAY_CSS_URL')
          end
        end

        # For the given order, initialize a new PaymentPage
        # @param [Spree::Order] order The order for which the payment is initialized
        # @return [ActiveMerchant::Billing::Response]
        def initialize_payment_page(order)
          payment_page_initialize = SixSaferpay::PaymentPage::Initialize.new(
            (order.total * 100).to_i,
            order.currency,
            order.number,
            order.to_s
          )

          saferpay_response = SixSaferpay::Client.post(payment_page_initialize)

          # TODO: Let the client handle this
          response_hash = JSON.parse(saferpay_response.body).with_indifferent_access
          response = InitializeResponse.new(
            token: response_hash[:Token],
            expiration: response_hash[:Expiration],
            redirect_url: response_hash[:RedirectUrl]
          )

          # TODO: Find out if we need to pass options
          ActiveMerchant::Billing::Response.new(
            true, 
            "Saferpay Payment Page initialized successfully, token: #{response.token}",
            response_hash,
            # {
            #   test:,
            #   authorization:,
            #   fraud_review:,
            #   error_code:,
            #   emv_authorization:,
            #   avs_result:,
            #   cvv_result:,
            # }
          )

          # TODO: update error handler according to SixSaferpay gem Error classes
        rescue StandardError => e
          SolidusSixSaferpay::ErrorHandler.handle(e, level: :error)

          # TODO: Find out if we need to pass options
          ActiveMerchant::Billing::Response.new(
            false, 
            "Saferpay Payment Page could not be initialized",
            response_hash,
            # {
            #   test:,
            #   authorization:,
            #   fraud_review:,
            #   error_code:,
            #   emv_authorization:,
            #   avs_result:,
            #   cvv_result:,
            # }
          )
        end

        def assert(token)
          payment_page_assert = SixSaferpay::PaymentPage::Assert.new(token)

          saferpay_response = SixSaferpay::Client.post(payment_page_assert)

          # TODO: Let the Client handle this
          response_hash = JSON.parse(saferpay_response.body).with_indifferent_access

          response = AssertResponse.new(
            transaction: response_hash[:Transaction],
            payment_means: response_hash[:PaymentMeans],
            liability: response_hash[:Liability],
          )

          ActiveMerchant::Billing::Response.new(
            true,
            "Saferpay Payment Page assert response: #{response}",
            response_hash
          )
        rescue StandardError => e
          SolidusSixSaferpay::ErrorHandler.handle(e, level: :error)

          ActiveMerchant::Billing::Response.new(
            false,
            "Saferpay Payment Page assert could not be requested",
            response_hash
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
          payment_page_capture = SixSaferpay::Transaction::Capture.new(transaction_id)

          saferpay_response = SixSaferpay::Client.post(payment_page_capture)

          # TODO: Let the Client handle this
          response_hash = JSON.parse(saferpay_response.body).with_indifferent_access

          response = CaptureResponse.new(
            capture_id: response_hash[:CaptureId],
            status: response_hash[:Status],
            date: response_hash[:Date]
          )

          ActiveMerchant::Billing::Response.new(
            true,
            "Saferpay Payment Page capture response: #{response}",
            response_hash
          )
        rescue StandardError => e
          SolidusSixSaferpay::ErrorHandler.handle(e, level: :error)

          ActiveMerchant::Billing::Response.new(
            false,
            "Saferpay Payment Page capture failed",
            response_hash
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
