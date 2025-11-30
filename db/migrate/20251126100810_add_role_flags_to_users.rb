class AddRoleFlagsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    add_index :users, :admin

    add_column :users, :super_admin, :boolean, default: false, null: false
    add_index :users, :super_admin

    reversible do |dir|
      dir.up do
        User.reset_column_information
        User.where(email: 'admin@ebazzari.com').update_all(admin: true, super_admin: true)
      end
    end
  end
end
