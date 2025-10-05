class CreateLandings < ActiveRecord::Migration[8.0]
  def change
    create_table :landings do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.string :template_key, null: false
      t.jsonb :settings, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :landings, [:project_id, :active]
  end
end
