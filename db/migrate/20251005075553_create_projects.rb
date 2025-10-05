class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
