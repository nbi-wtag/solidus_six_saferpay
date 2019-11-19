module Spree
  module SolidusSixSaferpay
    class InquireTransactionPayment < InquirePayment
      include UseTransactionGateway
    end
  end
end
