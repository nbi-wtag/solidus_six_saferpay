require 'rails_helper'

module SolidusSixSaferpay
  RSpec.describe PaymentPageGateway do

    # config options
    let(:customer_id) { 'CUSTOMER_ID' }
    let(:terminal_id) { 'TERMINAL_ID' }
    let(:username) { 'USERNAME' }
    let(:password) { 'PASSWORD' }
    let(:success_url) { '/api/endpoints/success' }
    let(:fail_url) { '/api/endpoints/fail' }
    let(:base_url) { 'https://test.saferpay-api-host.test' }
    let(:css_url) { '/custom/css/url' }

    let(:gateway) do
      described_class.new(
        customer_id: customer_id,
        terminal_id: terminal_id,
        username: username,
        password: password,
        base_url: base_url,
        css_url: css_url
      )
    end

    let(:order) { create(:order, total: 100) }
    let(:payment_method) { create(:saferpay_payment_method) }

    let(:payment) { create(:six_saferpay_payment, order: order, payment_method: payment_method) }

    before do
      allow(ENV).to receive(:fetch).with('SIX_SAFERPAY_CUSTOMER_ID').and_return(customer_id)
      allow(ENV).to receive(:fetch).with('SIX_SAFERPAY_TERMINAL_ID').and_return(terminal_id)
      allow(ENV).to receive(:fetch).with('SIX_SAFERPAY_USERNAME').and_return(username)
      allow(ENV).to receive(:fetch).with('SIX_SAFERPAY_PASSWORD').and_return(password)
      allow(ENV).to receive(:fetch).with('SIX_SAFERPAY_BASE_URL').and_return(base_url)
      allow(ENV).to receive(:fetch).with('SIX_SAFERPAY_CSS_URL').and_return(css_url)
    end

    describe '#initialize' do
      it 'configures the API client with correct urls by default' do
        described_class.new

        config = SixSaferpay.config

        expect(config.success_url).to eq(solidus_six_saferpay_payment_page_success_url)
        expect(config.fail_url).to eq(solidus_six_saferpay_payment_page_fail_url)
      end
    end

    # TODO: DANI
    xdescribe '#initialize_payment' do

      let(:saferpay_address) do
        SixSaferpay::Address.new(
          first_name: order.shipping_address.first_name,
          last_name: order.shipping_address.last_name,
          date_of_birth: nil,
          company: nil,
          gender: nil,
          legal_form: nil,
          street: order.shipping_address.address1,
          street_2: nil,
          zip: order.shipping_address.zipcode,
          city: order.shipping_address.city,
          country_subdevision_code: nil,
          country_code: order.shipping_address.country.iso,
          phone: nil,
          email: nil,
        )
      end

      let(:initialize_params) do
        {
          payment: SixSaferpay::Payment.new(
            amount: SixSaferpay::Amount.new(value: (order.total * 100), currency_code: order.currency),
            order_id: order.number,
            description: order.number
          ),
          payer: SixSaferpay::Payer.new(
            language_code: :en,
            billing_address: saferpay_address,
            delivery_address: saferpay_address
          )
        }
      end

      it 'initializes a payment page payment' do
        expect(SixSaferpay::SixPaymentPage::Initialize).to receive(:new).with(initialize_params).and_call_original

        expect(SixSaferpay::Client).to receive(:post).with(instance_of(SixSaferpay::SixPaymentPage::Initialize))

        gateway.initialize_payment(order, payment_method)
      end
    end
  end
end
