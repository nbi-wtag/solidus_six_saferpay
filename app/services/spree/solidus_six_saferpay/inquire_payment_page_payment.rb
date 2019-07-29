module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class InquirePaymentPagePayment < InquirePayment
      include UsePaymentPageGateway
    end
  end
end
