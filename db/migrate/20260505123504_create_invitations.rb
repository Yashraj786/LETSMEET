# frozen_string_literal: true

# Invitations are the mechanism by which members bring prospects into the network.
# Each invitation consumes one use from a referral code and creates a cryptographic
# token that gates the sign-up flow.
class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :sender,        null: false, foreign_key: { to_table: :users }
      t.references :referral_code, null: false, foreign_key: true

      # The prospect's email — validated before the invite is dispatched
      t.string  :recipient_email, null: false

      # Opaque one-time-use token embedded in the invitation URL
      t.string  :token,           null: false

      # 0=pending, 1=accepted, 2=expired, 3=revoked
      t.integer :status,          null: false, default: 0

      t.datetime :accepted_at,    null: true
      t.datetime :expires_at,     null: false

      t.timestamps null: false
    end

    add_index :invitations, :token,          unique: true
    add_index :invitations, :recipient_email
    add_index :invitations, [ :sender_id, :status ]
  end
end
