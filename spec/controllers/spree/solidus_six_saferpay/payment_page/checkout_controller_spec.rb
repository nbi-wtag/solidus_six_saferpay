require 'rails_helper'

RSpec.describe Spree::SolidusSixSaferpay::PaymentPage::CheckoutController, type: :controller do
  routes { Spree::Core::Engine.routes }

  let(:user) { create(:user) }
  let(:order) { create(:order) }
  let(:payment_method) { create(:saferpay_payment_method) }

  let(:subject) { described_class.new }

  before do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages current_order: order
  end

  describe 'GET init' do
    it 'initializes the saferpay payment', :focus do
      get :init, params: { payment_method_id: payment_method.id }
      expect(subject).to receive(:initialize_payment).with(order, payment_method)
    end
  end

  describe 'GET success' do

  end

  describe 'GET fail' do

  end
end
