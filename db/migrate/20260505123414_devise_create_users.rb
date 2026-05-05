# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable — sign-in analytics for the platform
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable — all members must verify email before access
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      ## Lockable — protect against brute-force attacks
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      ## Platform-specific fields
      # Role: 0=member (default), 1=admin — stored as integer enum
      t.integer :role, null: false, default: 0

      # Referral gatekeeping — every user is brought in through an invite chain
      t.references :invited_by, null: true, foreign_key: { to_table: :users }
      t.string :referral_code_used, null: true

      t.timestamps null: false
    end

    add_index :users, :email,              unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token,       unique: true
  end
end
