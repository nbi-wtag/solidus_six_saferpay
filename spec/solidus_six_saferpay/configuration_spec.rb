require 'rails_helper'

module SolidusSixSaferpay
  RSpec.describe Configuration do

    describe '.config' do
      it 'yields itself to be configured' do
        yielded_instance = nil
        new_instance = described_class.config {|c| yielded_instance = c }
        expect(yielded_instance).to be new_instance
      end

      it 'exposes a configurable list of error handlers' do
        expect(described_class).to respond_to(:error_handlers)
      end
    end
  end
end
