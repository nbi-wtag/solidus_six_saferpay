module Spree
  module SolidusSixSaferpay
    class ProcessTransactionPayment < ProcessAuthorizedPayment
      include UseTransactionGateway
    end
  end
end
