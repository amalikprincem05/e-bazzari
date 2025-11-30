class AddReferralFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :referral_code, :string
    add_index :users, :referral_code, unique: true

    add_reference :users, :referred_by, foreign_key: { to_table: :users }

    add_column :users, :points, :integer, default: 0, null: false
  end
end
