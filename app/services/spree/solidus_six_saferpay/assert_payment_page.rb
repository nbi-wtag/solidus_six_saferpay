module Spree
  module SolidusSixSaferpay
    class AssertPaymentPage < AuthorizePayment
      include UsePaymentPageGateway
    end
  end
end

