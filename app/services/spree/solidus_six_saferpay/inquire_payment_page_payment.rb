module Spree
  module SolidusSixSaferpay
    class InquirePaymentPagePayment < InquirePayment
      include UsePaymentPageGateway
    end
  end
end
