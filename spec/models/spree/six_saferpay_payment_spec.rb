require 'rails_helper'

module Spree
  RSpec.describe SixSaferpayPayment, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to :order }
      it { is_expected.to belong_to :payment_method }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of :token }
      it { is_expected.to validate_presence_of :expiration }
    end
  end
end

