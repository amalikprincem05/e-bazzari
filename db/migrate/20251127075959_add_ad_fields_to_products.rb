class AddAdFieldsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :featured_ad, :boolean, null: false, default: false
    add_column :products, :featured_badge, :string, null: false, default: 'Featured'
    add_column :products, :featured_priority, :integer, null: false, default: 0

    add_index :products, :featured_ad
    add_index :products, :featured_priority
  end
end
