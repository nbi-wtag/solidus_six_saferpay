module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class AuthorizeTransaction < AuthorizePayment
      include UseTransactionGateway
    end
  end
end

