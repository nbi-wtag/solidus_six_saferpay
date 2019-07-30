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

Finally, add the following javascript to your `application.js` manifest file:

```javascript
//= ...
//= require spree <= This must be above the saferpay_payment line
//= ...
//= require solidus_six_saferpay/saferpay_payment
```

## Configuration and Usage
After adding the `solidus_six_saferpay` gem to your Solidus Rails app, you can create new payment methods `Saferpay Payment Page` and `Saferpay Transaction` in the admin backend under "Settings" > "Payment". When adding a new Saferpay payment method, you can configure the payment method with the information you have received from SIX when creating a new test account.

### Configuration Options

Notable configuration options are:

* `as_iframe`: If checked, the payment form is displayed on the "Payment" checkout page. If unchecked, the user needs to select a payment method and then proceed with the checkout to be redirected to the saferpay payment interface.
* `require_liability_shift`: If checked, payments are only accepted if saferpay grants liability shift for the payment. If a payment has no liability shift, then the checkout process fails and the customer needs to use other means of payment.

All other configuration options are restrictions for available payment methods. If you don't check any payment methods, then the interface will make all payment methods available. If you restrict the available payment methods for the user, the interface will reflect your choice. If you select only a single payment method, the user is directly forwarded to the input form for the selected payment method without having to choose themselves.

### Customizing the Confirm Page
If you want to display the masked number on the confirm page, you must override the default `_payment.html.erb` partial of spree so that the provided partial can be rendered (instead of just displaying the name of your payment method).

```erb
<!-- This is the default "app/views/spree/payments/_payment.html.erb" (including our modification) -->
<% source = payment.source %>

<!-- Add this code to render our provided partial that shows the masked number -->
<% if source.is_a?(Spree::SixSaferpayPayment) %>
  <%= render source, payment: payment %>
<% end %>

<!-- turn this "if" into an "elsif" to prevent rendering the payment method name -->
<% elsif source.is_a?(Spree::CreditCard) %>
  <span class="cc-type">
    <% unless (cc_type = source.cc_type).blank? %>
      <%= image_tag "credit_cards/icons/#{cc_type}.png" %>
    <% end %>
    <% if source.last_digits %>
      <%= t('spree.ending_in') %> <%= source.last_digits %>
    <% end %>
  </span>
  <br />
  <span class="full-name"><%= source.name %></span>
<% elsif source.is_a?(Spree::StoreCredit) %>
  <%= content_tag(:span, payment.payment_method.name) %>:
  <%= content_tag(:span, payment.display_amount) %>
<% else %>
  <%= content_tag(:span, payment.payment_method.name) %>
<% end %>
```

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
