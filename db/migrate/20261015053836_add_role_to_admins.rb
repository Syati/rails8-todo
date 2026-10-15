class AddRoleToAdmins < ActiveRecord::Migration[8.1]
  def up
    # 0: super_admin, 1: operator. New admins default to operator.
    add_column :admins, :role, :integer, null: false, default: 1

    # Admins created before roles existed had full access, so keep it.
    # Otherwise no super_admin would remain to manage other admins.
    execute "UPDATE admins SET role = 0"
  end

  def down
    remove_column :admins, :role
  end
end
