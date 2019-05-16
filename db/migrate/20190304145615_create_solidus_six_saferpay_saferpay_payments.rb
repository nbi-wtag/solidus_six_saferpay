class CreateSolidusSixSaferpaySaferpayPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :solidus_six_saferpay_saferpay_payments do |t|
      t.string :token
      t.references :order, foreign_key: true
      t.text :response_hash

      t.timestamps
    end
    add_index :solidus_six_saferpay_saferpay_payments, :token, unique: true
  end
end
