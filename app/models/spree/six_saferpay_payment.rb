module Spree

  # TODO: SPEC
  #
  # attributes
  # * token
  # * expiration
  # * redirect_url ?
  # * capture_id
  # * response_hash (redundant, serialized)
  class SixSaferpayPayment < PaymentSource
    belongs_to :order
    belongs_to :payment_method
    # store this anyway for accountability reasons
    serialize :response_hash, Hash

    validates :token, :expiration, presence: true
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
