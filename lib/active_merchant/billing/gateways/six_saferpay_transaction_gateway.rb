module ActiveMerchant
  module Billing
    module Gateways
      class SixSaferpayTransactionGateway < SixSaferpayGateway

        def initialize_transaction(order, payment_method)
          amount = Spree::Money.new(order.total, currency: order.currency)
          payment = SixSaferpay::Payment.new(
            amount: SixSaferpay::Amount.new(value: amount.cents, currency_code: amount.currency.iso_code),
            order_id: order.number,
            description: order.number
          )

          six_payment_methods = payment_method.enabled_payment_methods
          params = { payment: payment }
          params.merge!(payment_methods: six_payment_methods) unless six_payment_methods.blank?
          transaction_initialize = SixSaferpay::SixTransaction::Initialize.new(params)
          initialize_response = SixSaferpay::Client.post(transaction_initialize)

          response(
            success: true, 
            message: "Saferpay Payment Page initialized successfully, token: #{initialize_response.token}",
            params: initialize_response.to_h.with_indifferent_access,
          )

          # TODO: update error handler according to SixSaferpay gem Error classes
        rescue StandardError => e
          handle_error(e, initialize_response)
        end

        # Allocate the reqested amount for a payment
        def authorize(amount, payment_source, options = {})
          payment_page_assert = SixSaferpay::SixTransaction::Authorize.new(token: payment_source.token)
          saferpay_response = SixSaferpay::Client.post(payment_page_assert)

          ensure_valid_payment(payment_source, saferpay_response)

          update_payment_source!(payment_source, saferpay_response)

          response(
            success: true,
            message: "Saferpay Transaction authorize response: #{saferpay_response}",
            params: saferpay_response.to_h
          )
        rescue SixSaferpay::Error => e
          handle_error(e, saferpay_response)
        rescue InvalidSaferpayPayment => e
          handle_error(e, saferpay_response)
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

        private

        # TODO: Replace with API
        def initialize_request(order)
          hash = {}
          hash[:RequestHeader] = SixSaferpay::RequestHeader.new.to_h
          hash[:TerminalId] = SixSaferpay.config.terminal_id
          hash[:Payment] = {
            Amount: { Value: (order.total * 100).to_i, CurrencyCode: order.currency },
            OrderId: order.number,
            Description: order.number
          }
          hash[:ReturnUrls] = SixSaferpay::ReturnUrls.new.to_h

          saferpay_request(hash, '/Payment/v1/Transaction/Initialize')
        end

        def authorize_request(payment_source)

          hash = {}
          hash[:RequestHeader] = SixSaferpay::RequestHeader.new.to_h
          hash[:Token] = payment_source.token

          saferpay_request(hash, '/Payment/v1/Transaction/Authorize')
        end

        def saferpay_request(body, url_endpoint)
          client = SixSaferpay::Client.new("dani")
          url = URI.parse(client.send(:base_url) + url_endpoint)
          request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})

          body = body.deep_transform_keys do |key|
            key = key.to_s.camelize
            key.to_sym
          end

          request.body = body.to_json
          request.basic_auth(client.send(:username), client.send(:password))

          post_request(url, request)
        end

        # TODO: Replace with API
        def post_request(url, request)
          https = Net::HTTP.new(url.host, url.port)
          https.use_ssl = true
          response = https.request(request)
          body = response.body
          hash = JSON.parse(body, symbolize_names: true)
          hash = hash.deep_transform_keys do |key|
            key = key.to_s.underscore
            key.to_sym
          end
          if response.code == "200"
            hash
          else
            raise SixSaferpay::Error.new(hash)
          end
        end

      end
    end
  end
end
