class CreateLandingAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :landing_assets do |t|
      t.references :landing, null: false, foreign_key: true
      t.string :field_key

      t.timestamps
    end
    add_index :landing_assets, :field_key
  end
end
