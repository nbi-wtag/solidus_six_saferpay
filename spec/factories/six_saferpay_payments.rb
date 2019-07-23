FactoryBot.define do

  factory :six_saferpay_payment, class: Spree::SixSaferpayPayment do
    order
    sequence(:token, (0..10000).to_a.shuffle.to_enum)
    expiration { Time.current + 2.hours }
    redirect_url { "six_saferpay/api/redirect_url" }
  end
end
