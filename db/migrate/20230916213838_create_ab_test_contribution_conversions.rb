class CreateAbTestContributionConversions < ActiveRecord::Migration[7.0]
  def change
    create_table :ab_test_contribution_conversions do |t|
      t.string :session_id
      t.references :project, null: false, foreign_key: true
      t.references :contribution, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :ab_test_name
      t.string :ab_test_variant
      t.integer :ab_test_version
      t.string :status
      t.jsonb :metadata

      t.timestamps
    end
  end
end
