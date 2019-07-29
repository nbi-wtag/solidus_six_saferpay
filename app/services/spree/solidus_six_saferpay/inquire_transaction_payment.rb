module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class InquireTransactionPayment < InquirePayment
      include UseTransactionGateway
    end
  end
end
