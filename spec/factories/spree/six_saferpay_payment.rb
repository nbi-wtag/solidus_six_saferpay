FactoryBot.define do
  factory :six_saferpay_payment, class: Spree::SixSaferpayPayment do
    order
    expiration { Time.current + 2.hours }
    sequence(:token, (1..100000).to_a.shuffle.to_enum)
  end
end
