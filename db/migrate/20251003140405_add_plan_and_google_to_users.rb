class AddPlanAndGoogleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :plan, :integer, null: false, default: 0
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :avatar_url, :string

    add_index :users, [:provider, :uid], unique: true
    add_index :users, :plan
  end
end