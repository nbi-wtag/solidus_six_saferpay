module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class AssertPaymentPage < AuthorizePayment
      include UsePaymentPageGateway
    end
  end
end

