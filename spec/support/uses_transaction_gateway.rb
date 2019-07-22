RSpec.shared_examples "it uses the transaction gateway" do

  # it_behaves_like "it has route access"

  describe '#gateway' do
    it 'configures the gateway urls correctly' do
      expect(::SolidusSixSaferpay::TransactionGateway).to receive(:new).with(
        success_url: Spree::Core::Engine.routes.url_helpers.solidus_six_saferpay_payment_page_init_url,
        fail_url: Spree::Core::Engine.routes.url_helpers.solidus_six_saferpay_payment_page_fail_url
      )
      subject.gateway
    end

    context 'when the gateway is configured correctly' do
      before do
        allow(ENV).to receive(:fetch).with("SIX_SAFERPAY_CUSTOMER_ID").and_return("customer_id")
        allow(ENV).to receive(:fetch).with("SIX_SAFERPAY_TERMINAL_ID").and_return("terminal_id")
        allow(ENV).to receive(:fetch).with("SIX_SAFERPAY_USERNAME").and_return("username")
        allow(ENV).to receive(:fetch).with("SIX_SAFERPAY_PASSWORD").and_return("password")
        allow(ENV).to receive(:fetch).with("SIX_SAFERPAY_BASE_URL").and_return("base_url")
      end

      it 'should return a PaymentPageGateway' do
        expect(subject.gateway).to be_a(::SolidusSixSaferpay::PaymentPageGateway)
      end

    end
  end
end

