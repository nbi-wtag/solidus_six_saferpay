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

# PAYMENT PAGE INITIALIZE RESPONSE
# {
#   "ResponseHeader": {
#     "SpecVersion": "1.10",
#     "RequestId": "Id of the request"
#   },
#   "Token": "234uhfh78234hlasdfh8234e1234",
#   "Expiration": "2015-01-30T12:45:22.258+01:00",
#   "RedirectUrl": "https://www.saferpay.com/vt2/api/..."
# }
#
# PAYMENT PAGE ASSERT RESPONSE
# {
#   "ResponseHeader": {
#     "SpecVersion": "1.10",
#     "RequestId": "[your request id]"
#   },
#   "Transaction": {
#     "Type": "PAYMENT",
#     "Status": "AUTHORIZED",
#     "Id": "723n4MAjMdhjSAhAKEUdA8jtl9jb",
#     "Date": "2015-01-30T12:45:22.258+01:00",
#     "Amount": {
#       "Value": "100",
#       "CurrencyCode": "CHF"
#     },
#     "AcquirerName": "Saferpay Test Card",
#     "AcquirerReference": "000000",
#     "SixTransactionReference": "0:0:3:723n4MAjMdhjSAhAKEUdA8jtl9jb",
#     "ApprovalCode": "012345"
#   },
#   "PaymentMeans": {
#     "Brand": {
#       "PaymentMethod": "VISA",
#       "Name": "VISA Saferpay Test"
#     },
#     "DisplayText": "9123 45xx xxxx 1234",
#     "Card": {
#       "MaskedNumber": "912345xxxxxx1234",
#       "ExpYear": 2015,
#       "ExpMonth": 9,
#       "HolderName": "Max Mustermann",
#       "CountryCode": "CH"
#     }
#   },
#   "Liability": {
#     "LiabilityShift": true,
#     "LiableEntity": "ThreeDs",
#     "ThreeDs": {
#       "Authenticated": true,
#       "LiabilityShift": true,
#       "Xid": "ARkvCgk5Y1t/BDFFXkUPGX9DUgs=",
#       "VerificationValue": "AAABBIIFmAAAAAAAAAAAAAAAAAA="
#     },
#     "FraudFree": {
#       "Id": "deab90a0458bdc9d9946f5ed1b36f6e8",
#       "LiabilityShift": false,
#       "Score": 0.6,
#       "InvestigationPoints": [
#         "susp_bill_ad",
#         "susp_machine"
#       ]
#     }
#   }
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
