# SolidusSixSaferpay
The `solidus_six_saferpay` engine adds checkout options for the Saferpay Payment Page ([Integration Guide](https://saferpay.github.io/sndbx/Integration_PP.html), [JSON API documentation](http://saferpay.github.io/jsonapi/#ChapterPaymentPage)) and the Saferpay Transaction ([Integration Guide](https://saferpay.github.io/sndbx/Integration_trx.html), [JSON API documentation](https://saferpay.github.io/sndbx/Integration_trx.html)).


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'solidus_six_saferpay'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install solidus_six_saferpay
```

After installing the gem, copy the migrations to your host application and migrate:

```bash
$ bundle exec rails solidus_six_saferpay:install:migrations
$ bundle exec rails db:migrate
```

## Configuration and Usage
After adding the `solidus_six_saferpay` gem to your Solidus Rails app, you can create new payment methods `Saferpay Payment Page` and `Saferpay Transaction` in the admin backend under "Settings" > "Payment". When adding a new Saferpay payment method, you can configure the payment method with the information you have received from SIX when creating a new test account.

## How it works

### Payment Page
When the payment step is reached during the checkout process of an order, the user can now select the configured payment methods. When a Saferpay payment method is selected and the user proceeds with the checkout process, 

### Technical implementation Payment Page
#### Checkout: Payment Initialize
On the payment page of the checkout process, solidus renders a partial for all active and available payment methods. Our partial is called `_saferpay_payment_page`.
When the partial is loaded, an AJAX request goes to the `SaferpayPaymentPageController#init_payment_page` action.
From there, we make a request to the Saferpay server to initialize the Payment Page. This request happens via the SixSaferpay Gateway and is abstracted away in the `InitializeSaferpayPaymentPage` service.

Iff this request is successful, a new `SaferpayPayment` object is created. This object contains the Saferpay `Token` for the current payment and links it with the current `Spree::Order`. It also stores the response of the `PaymentPageInitialize` request in hash form.

If the initialize request is not successful, then TODO (at the moment raise)

When the `PaymentPageInitialize` request was successful, the user can now enter the payment information in the form provided by Saferpay. When the form is submitted, Saferpay then redirects either to a success url, a cancel url or a fail url depending on the submitted information and performed actions of the user.

#### Checkout: Payment Success
If Saferpay can successfully process the user-submitted information, then Saferpay redirects the user to a `SuccessUrl`, which is configured to be handled by `SaferpayPaymentPageController#success`.

In this `#success` action, we find the `SaferpayPayment` object with the correct token that was created in the `PaymentPageInitialize` request. If this token is found, a `PaymentPageAssert` request is performed (abstracted away the `AssertSaferpayPaymentPage` service).

Iff this assert request is successful, the user is redirected to the confirm page of the checkout process. See [the Confirm process](#checkout:-confirm).

If the assert request is not successful, then (TODO).

#### Checkout: Payment Cancel
At the moment, raise an error (TODO)

#### Checkout: Payment Fail
At the moment, raise an error (TODO)


#### Checkout: Confirm
When the user confirms the purchase in the checkout process, the saferpay payment is automatically captured. To do this, the SixSaferpay gateway authorizes and then captures the




## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
