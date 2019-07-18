module Spree

  # TODO: SPEC
  #
  # attributes
  # * :token
  # * :expiration
  # * :redirect_url
  # * :transaction_id
  # * :transaction_status
  # * :transaction_date
  # * :six_transaction_reference
  # * :display_text
  # * :masked_number
  # * :expiration_year
  # * :expiration_month
  # * :response_hash
  class SixSaferpayPayment < PaymentSource
    belongs_to :order
    belongs_to :payment_method
    # store this anyway for accountability reasons
    serialize :response_hash, Hash

    validates :token, :expiration, presence: true

    def create_payment!
      payments.create(order: order, response_code: transaction_id, payment_method: payment_method, amount: order.total, source: self)
    end

    def address
      @address ||= order.bill_address
    end

    def payment_means
      @payment_means ||= ::SixSaferpay::ResponsePaymentMeans.new(response_hash[:payment_means])
    end

    def card
      payment_means.card
    end

    def name
      card.holder_name
    end

    def brand_name
      payment_means.brand.name
    end

    def month
      card.exp_month
    end

    def year
      card.exp_year
    end

    # TODO: Store directly
    def icon_name
      payment_means.brand.payment_method.downcase
    end
  end
end
