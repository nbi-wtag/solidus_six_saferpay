require 'rails_helper'

module Spree
  module SolidusSixSaferpay
    RSpec.describe PaymentPageCheckoutController, type: :controller do

      let(:order) { create(:order) }
      let(:payment_method) { create(:saferpay_payment_method) }

      let(:subject) { described_class.new }

      describe 'GET init', :focus do
        it 'initializes the saferpay payment' do
          expect(subject).to receive(:initialize_payment).with(order, payment_method)

          # get '/solidus_six_saferpay/payment_page/init', params: { payment_method_id: payment_method.id }
          get 'solidus_six_saferpay/payment_page/init', params: { payment_method_id: payment_method.id }
        end
      end

      describe 'GET success' do
        
      end

      describe 'GET fail' do
        
      end
    end
  end
end
