class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :email
      t.string :idea_slug
      t.string :source

      t.timestamps
    end
  end
end
