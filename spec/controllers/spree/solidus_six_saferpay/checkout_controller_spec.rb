require 'rails_helper'

RSpec.describe Spree::SolidusSixSaferpay::CheckoutController, type: :controller do
  routes { Spree::Core::Engine.routes }

  let(:user) { create(:user) }
  let(:order) { create(:order) }
  let(:payment_method) { create(:saferpay_payment_method_transaction) }
  let(:payment) { create(:six_saferpay_payment) }

  let(:subject) { described_class.new }

  before do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages current_order: order
  end

  describe '#initialize_payment' do
    it 'is not implemented in this superclass' do
      expect { subject.send(:initialize_payment, order, payment_method) }.to raise_error(NotImplementedError)
    end
  end

  describe '#authorize_payment' do
    it 'is not implemented in this superclass' do
      expect { subject.send(:authorize_payment, payment) }.to raise_error(NotImplementedError)
    end
  end

  describe '#process_authorization' do
    it 'is not implemented in this superclass' do
      expect { subject.send(:process_authorization, payment) }.to raise_error(NotImplementedError)
    end
  end

  describe '#inquire_payment' do
    it 'is not implemented in this superclass' do
      expect { subject.send(:inquire_payment, payment) }.to raise_error(NotImplementedError)
    end
  end
end
