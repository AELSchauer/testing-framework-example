class CreateUserSessions < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :user_sessions, uuid: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :uuid
      t.references :user, null: false, foreign_key: true
      t.timestamp :session_start
      t.timestamp :session_end

      t.timestamps
    end
  end
end
