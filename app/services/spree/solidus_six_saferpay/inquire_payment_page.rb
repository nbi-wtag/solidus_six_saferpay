module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class InquirePaymentPage < InquirePayment
      include UsePaymentPageGateway
    end
  end
end
