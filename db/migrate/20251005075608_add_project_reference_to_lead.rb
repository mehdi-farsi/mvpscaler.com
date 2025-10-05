class AddProjectReferenceToLead < ActiveRecord::Migration[8.0]
  def change
    add_reference :leads, :project, index: true, null: false
  end
end
