class AddProjectToContribution < ActiveRecord::Migration[7.0]
  def change
    add_reference :contributions, :project, null: false, foreign_key: true
  end
end
