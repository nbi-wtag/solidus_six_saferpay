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
  attr_reader

  def initialize(transaction:, payment_means:, liability:)
    @transaction = transaction
    @payment_means = payment_means
    @liability = liability
  end
end

module ActiveMerchant
  module Billing
    module Gateways
      class SixSaferpayTransactionGateway < Gateway
        # * <tt>purchase(money, credit_card, options = {})</tt>
        # * <tt>authorize(money, credit_card, options = {})</tt>
        # * <tt>capture(money, authorization, options = {})</tt>
        # * <tt>void(identification, options = {})</tt>
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

        # TODO: REMOVE THIS B/C IT IS UNUSED FOR TRANSACTION INTERFACE
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
          SolidusSixPayments::ErrorHandler.handle(e, level: :error)

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
          SolidusSixPayments::ErrorHandler.handle(e, level: error)

          ActiveMerchant::Billing::Response.new(
            false,
            "Saferpay Payment Page assert could not be requested",
            response_hash
          )
        end

        # Defined by solidus to combine authorize + capture
        def purchase(amount, payment_source, options = {})
          require 'pry'; binding.pry
          auth_response = authorize(amount, payment_source, options)
          if auth_response.success?
            capture(amount, payment_source.order_id, options)
          else
            auth_response
          end
        end

        # Allocate the reqested amount for a payment
        def authorize(amount, credit_card_payment_source, options = {})
          # raise "#authorize has not been implemented yet for this gateway"
          require 'pry'; binding.pry
          # TODO:
          # - post request
          # - parse response
          # - handle errors
          # - ???
          # - return AM response
        end

        # Finalize an authorized payment
        def capture(amount, authorization, options={})
          require 'pry'; binding.pry
          # TODO:
          # - post request
          # - parse response
          # - handle errors
          # - ???
          # - return AM response
        end

        # Release authorized uncaptured payments
        def void(identification, options = {})
          # TODO:
          # - ???
        end


        # Return previously captured payment
      def refund(amount, order_id, options={})
        # TODO:
        # - post request
        # - parse response
        # - handle errors
        # - ???
        # - return AM response
      end

      # ???
      def verify(credit_card_payment_source, options = {})
        # TODO:
        # - ???
      end
    end
    end
  end
end

# module ActiveMerchant
#   module Billing
#     class KlarnaGateway < Gateway
#       class << self
#         undef_method :supports?
#       end

#       def initialize(options={})
#         @options = options

#         Klarna.configure do |config|
#           if @options[:api_secret].blank? || @options[:api_key].blank?
#             raise ::KlarnaGateway::InvalidConfiguration, "Missing mandatory API credentials"
#           end
#           config.environment = @options[:test_mode] ? 'test' : 'production'
#           config.country = @options[:country]
#           config.api_key =  @options[:api_key]
#           config.api_secret = @options[:api_secret]
#           config.user_agent = "Klarna Solidus Gateway/#{::KlarnaGateway::VERSION} Solidus/#{::Spree.solidus_version} Rails/#{::Rails.version}"
#         end
#       end

#       def create_session(order)
#         Klarna.client(:credit).create_session(order)
#       end

#       def update_session(session_id, order)
#         Klarna.client(:credit).update_session(session_id, order)
#       end

#       def purchase(amount, payment_source, options = {})
#         auth_response = authorize(amount, payment_source, options)
#         if auth_response.success?
#           capture(amount, payment_source.order_id, options)
#         else
#           auth_response
#         end
#       end

#       def authorize(amount, payment_source, options={})
#         # TODO: check if we get a better handle for the order
#         order = Spree::Order.find_by(number: options[:order_id].split("-").first)
#         region = payment_source.payment_method.options[:country]
#         serializer = ::KlarnaGateway::OrderSerializer.new(order, region)

#         response = Klarna.client(:credit).place_order(payment_source.authorization_token, serializer.to_hash)
#         update_payment_source_from_authorization(payment_source, response, order)
#         update_order(response, order)

#         if response.success?
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Placed order #{order.number} Klarna id: #{payment_source.order_id}",
#             response.body,
#             {
#               authorization: response.order_id,
#               fraud_review: payment_source.fraud_status
#             }
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             readable_error(response),
#             response.body,
#             {
#               error_code: response.error_code
#             }
#           )
#         end
#       end

#       def capture(amount, order_id, options={})
#         response = Klarna.client.capture(order_id, {captured_amount: amount, shipping_info: options[:shipping_info]})

#         if response.success?
#           capture_id = response['Capture-ID']
#           payment_source = Spree::KlarnaCreditPayment.find_by(order_id: order_id)
#           update_payment_source!(payment_source, order_id, capture_id: capture_id)

#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Captured order with Klarna id: '#{order_id}' Capture id: '#{capture_id}'",
#             response.body || {},
#             {
#               authorization: order_id,
#               fraud_review: payment_source.fraud_status
#             }
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             readable_error(response),
#             response.body || {},
#             {
#               error_code: response.error_code
#             }
#           )
#         end
#       end

#       def refund(amount, order_id, options={})
#         # Get the refunded line items for better customer communications
#         line_items = []
#         if options[:originator].present?
#           region = options[:originator].try(:payment).payment_method.options[:country]
#           line_items = Array(options[:originator].try(:reimbursement).try(:return_items)).map do |item|
#             ::KlarnaGateway::LineItemSerializer.new(item.inventory_unit.line_item, region)
#           end
#         end
#         response = Klarna.client(:refund).create(order_id, {refunded_amount: amount, order_lines: line_items})

#         if response.success?
#           update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Refunded order with Klarna id: #{order_id}",
#             response.body || {},
#             {
#               authorization: response['Refund-ID']
#             }
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             'Klarna Gateway: There was an error refunding this refund.',
#             response.body || {},
#             { error_code: response.error_code }
#           )
#         end
#       end

#       alias_method :credit, :refund

#       def get(order_id)
#         Klarna.client.get(order_id)
#       end

#       def acknowledge(order_id)
#         response = Klarna.client.acknowledge(order_id)

#         if response.success?
#           update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Extended Period for order with Klarna id: #{order_id}",
#             response.body || {}
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             'Klarna Gateway: There was an error processing this acknowledge.',
#             response.body || {},
#             {
#               error_code: response.error_code
#             }
#           )
#         end
#       end

#       def extend_period(order_id)
#         response = Klarna.client.extend(order_id)

#         if response.success?
#           update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Extended Period for order with Klarna id: #{order_id}",
#             response.body || {}
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             'Klarna Gateway: There was an error processing this period extension.',
#             response.body || {},
#             {
#               error_code: response.error_code
#             }
#           )
#         end
#       end

#       def release(order_id)
#         response = Klarna.client.release(order_id)

#         if response.success?
#           update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Released reamining amount for order with Klarna id: #{order_id}",
#             response.body || {},
#             {
#               authorization: order_id
#             }
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             'Klarna Gateway: There was an error processing this release.',
#             response.body || {},
#             {
#               error_code: response.error_code
#             }
#           )
#         end
#       end

#       def cancel(order_id)
#         response = Klarna.client.cancel(order_id)

#         if response.success?
#           update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Cancelled order with Klarna id: #{order_id}",
#             response.body || {},
#             {
#               authorization: order_id
#             }
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             'Klarna Gateway: There was an error cancelling this payment.',
#             response.body || {},
#             { error_code: response.error_code }
#           )
#         end
#       end

#       def shipping_info(order_id, capture_id, shipping_info)
#         response = Klarna.client(:capture).shipping_info(
#           order_id,
#           capture_id,
#           shipping_info
#         )
#         if response.success?
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Updated shipment info for order: #{order_id}, capture: #{capture_id}",
#             response.body || {},
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             "Cannot update the shipment info for order: #{order_id} capture: #{capture_id}",
#             response.body || {},
#             { error_code: response.error_code }
#           )
#         end
#       end

#       def customer_details(order_id, data)
#         response = Klarna.client.customer_details(
#           order_id,
#           data
#         )
#         if response.success?
#           ActiveMerchant::Billing::Response.new(
#             true,
#             "Updated customer details for order: #{order_id}",
#             response.body || {},
#           )
#         else
#           ActiveMerchant::Billing::Response.new(
#             false,
#             "Cannot update customer details for order: #{order_id}",
#             response.body || {},
#             { error_code: response.error_code }
#           )
#         end
#       end

#       def get_and_update_source(order_id)
#         update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
#       end

#       private

#       def update_order(response, order)
#         if response.success?
#           order.update_attributes(
#             klarna_order_id: response.order_id,
#             klarna_order_state: response.fraud_status
#           )
#         else
#           order.update_attributes(
#             klarna_order_id: nil,
#             klarna_order_state: response.error_code
#           )
#         end
#       end

#       def update_payment_source_from_authorization(payment_source, response, order)
#         payment_source.spree_order_id = order.id
#         payment_source.response_body = response.body
#         payment_source.redirect_url = response.redirect_url if response.respond_to?(:redirect_url)

#         if response.success?
#           payment_source.order_id = response.order_id
#           payment_source = update_payment_source(payment_source, response.order_id)
#         else
#           payment_source.error_code = response.error_code
#           payment_source.error_messages = response.error_messages
#           payment_source.correlation_id = response.correlation_id
#         end

#         payment_source.save!
#       end

#       def update_payment_source(payment_source, klarna_order_id, attributes = {})
#         get(klarna_order_id).tap do |klarna_order|
#           payment_source.status = klarna_order.status
#           payment_source.fraud_status = klarna_order.fraud_status
#           payment_source.expires_at = DateTime.parse(klarna_order.expires_at)
#           payment_source.assign_attributes(attributes)
#         end
#         payment_source
#       end

#       def update_payment_source!(payment_source, klarna_order_id, attributes = {})
#         update_payment_source(payment_source, klarna_order_id, attributes).tap do |order|
#           order.save!
#           order
#         end
#       end

#       def readable_error(response)
#         I18n.t(response.error_code.to_s.downcase, scope: "klarna.gateway_errors", default: "Klarna Gateway: Please check your payment method.")
#       end
#     end
#   end
# end

