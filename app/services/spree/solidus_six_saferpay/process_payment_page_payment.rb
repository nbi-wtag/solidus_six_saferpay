module Spree
  module SolidusSixSaferpay
    class ProcessPaymentPagePayment < ProcessAuthorizedPayment
      include UsePaymentPageGateway
    end
  end
end
