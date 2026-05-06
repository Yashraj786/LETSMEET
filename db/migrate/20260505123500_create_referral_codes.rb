# frozen_string_literal: true

# Referral codes are the gatekeeping backbone of the invite-only system.
# Each active member may hold multiple codes to distribute at their discretion.
class CreateReferralCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :referral_codes do |t|
      # The member who owns / issued this code
      t.references :user, null: false, foreign_key: true

      # Unique, opaque token presented to prospects
      t.string :token, null: false

      # Governance controls — admins can set caps and expiry per code
      t.integer  :max_uses,    null: false, default: 1
      t.integer  :uses_count,  null: false, default: 0
      t.datetime :expires_at,  null: true

      # Soft-deactivation without deletion keeps the audit trail intact
      t.boolean  :active, null: false, default: true

      t.timestamps null: false
    end

    add_index :referral_codes, :token, unique: true
    add_index :referral_codes, [ :user_id, :active ]
  end
end
