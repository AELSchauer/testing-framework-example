class CreateUserBehaviorTrackingEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :user_behavior_tracking_events do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
