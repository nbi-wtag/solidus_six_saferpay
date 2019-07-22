FactoryBot.define do

  factory :saferpay_payment_method, class: Spree::PaymentMethod::SaferpayPaymentMethod do
    name  { "saferpay_payment_method" }

    trait :payment_page do
      name { "saferpay payment_page" }
    end

    trait :transaction do
      name { "saferpay transaction" }
    end
  end
end
