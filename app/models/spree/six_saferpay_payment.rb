module Spree

  # TODO: SPEC
  #
  # attributes
  # * token
  # * expiration
  # * redirect_url ?
  # * capture_id
  # * response_hash (redundant, serialized)
  class SixSaferpayPayment < PaymentSource
    belongs_to :order
    belongs_to :payment_method
    # store this anyway for accountability reasons
    serialize :response_hash, Hash

    validates :token, :expiration, presence: true

    def create_payment!
      payments.create(order: order, payment_method: payment_method, source: self)
    end
  end
end
