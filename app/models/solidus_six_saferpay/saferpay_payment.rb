module SolidusSixSaferpay
  # TODO: SPEC
  class SaferpayPayment < ApplicationRecord
    belongs_to :order, class_name: "Spree::Order"

    serialize :response_hash, Hash
  end
end

# PAYMENT PAGE RESPONSE
# {
#   "ResponseHeader": {
#     "SpecVersion": "1.10",
#     "RequestId": "Id of the request"
#   },
#   "Token": "234uhfh78234hlasdfh8234e1234",
#   "Expiration": "2015-01-30T12:45:22.258+01:00",
#   "RedirectUrl": "https://www.saferpay.com/vt2/api/..."
# }

# TRANSACTION REPONSE
# {
#   "ResponseHeader": {
#     "SpecVersion": "1.10",
#     "RequestId": "[your request id]"
#   },
#   "Token": "234uhfh78234hlasdfh8234e",
#   "Expiration": "2015-01-30T12:45:22.258+01:00",
#   "LiabilityShift": false,
#   "RedirectRequired": true,
#   "Redirect": {
#     "RedirectUrl": "https://www.saferpay.com/vt2/Api/...",
#     "PaymentMeansRequired": true
#   }
# }
