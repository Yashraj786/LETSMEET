# frozen_string_literal: true

# Profiles are the public-facing identity layer — separate from the auth User
# to keep concerns clean and allow richer social data without polluting the auth table.
class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true

      t.string  :display_name, null: false, default: ""
      t.text    :bio,          null: true
      t.string  :location,     null: true
      t.string  :website,      null: true

      # Interests stored as a PostgreSQL text array for efficient querying
      t.text :interests, array: true, default: []

      # Privacy gate: members control their own visibility within the network
      t.boolean :public_profile, null: false, default: false

      t.timestamps null: false
    end

    add_index :profiles, :user_id, unique: true
    add_index :profiles, :display_name
    add_index :profiles, :interests, using: :gin
  end
end
