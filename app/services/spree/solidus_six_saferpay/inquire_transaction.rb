module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class InquireTransaction < InquirePayment
      include UseTransactionGateway
    end
  end
end
