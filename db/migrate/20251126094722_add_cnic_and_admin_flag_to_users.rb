class AddCnicAndAdminFlagToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :cnic, :string
    add_index :users, :cnic

    add_column :users, :created_by_admin, :boolean, null: false, default: false
    add_index :users, :created_by_admin

    add_index :users, :phone
  end
end
