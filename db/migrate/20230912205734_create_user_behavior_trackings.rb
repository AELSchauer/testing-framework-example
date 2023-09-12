class CreateUserBehaviorTrackings < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :user_behavior_trackings, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :user_session, null: false, foreign_key: true, type: :uuid
      t.references :user_behavior_tracking_events, null: false, foreign_key: true, index: { name: :index_user_behavior_trackings_on_tracking_events_id }
      t.string :browser
      t.string :device
      t.string :os
      t.jsonb :metadata
      t.string :trackable_type
      t.string :trackable_id

      t.timestamps
    end

    add_index :user_behavior_trackings, [:trackable_type, :trackable_id], name: :index_user_behavior_trackings_on_trackable
  end
end
