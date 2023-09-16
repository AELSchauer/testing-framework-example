class CreateContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :contributions do |t|
      t.references :user, null: true, foreign_key: true
      t.integer :amount
      t.boolean :paid

      t.timestamps
    end
  end
end
