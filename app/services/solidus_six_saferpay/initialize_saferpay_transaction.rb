# TODO: MOVE SERVICES OUT TO /spree NAMESPACE (again...)
module SolidusSixSaferpay

  # TODO: SPEC
  # TODO: Ensure that we invalidate old payments (they don't get invalidated when already processing)
  class InitializeSaferpayTransaction

    attr_reader :order, :payment_method, :payment, :redirect_url

    def self.call(order, payment_method)
      new(order, payment_method).call
    end

    def initialize(order, payment_method)
      @order = order
      @payment_method = payment_method
    end

    def call
      initialize_response = ActiveMerchant::Billing::Gateways::SixSaferpayTransactionGateway.new.initialize_transaction(order, payment_method)

      if initialize_response.success?
        @payment = Spree::PaymentCreate.new(order, payment_attributes(initialize_response.params)).build
        @redirect_url = initialize_response.params[:redirect][:redirect_url]
        @success = @payment.save!
      end
      self
    end

    def success?
      @success
    end

    private

    def payment_attributes(response_params)
      {
        amount: order.total,
        payment_method_id: payment_method.id,
        source_attributes: {
          order_id: order.id,
          token: response_params[:token],
          expiration: DateTime.parse(response_params[:expiration]),
          redirect_url: response_params[:redirect][:redirect_url],
        }
      }
    end

  end
end
