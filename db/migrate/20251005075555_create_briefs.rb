class CreateBriefs < ActiveRecord::Migration[8.0]
  def change
    create_table :briefs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :audience, null: false
      t.text :problem, null: false
      t.text :product_idea, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :locked_at
      t.jsonb :outputs
      t.jsonb :theme
      t.jsonb :raw_response
      t.string :model_used
      t.jsonb :usage
      t.timestamps
    end
  end
end
