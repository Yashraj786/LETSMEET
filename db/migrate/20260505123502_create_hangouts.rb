# frozen_string_literal: true

# Hangouts are the core unit of value — the exclusive events / gatherings
# that members organise and attend. Both virtual and IRL are supported.
class CreateHangouts < ActiveRecord::Migration[8.1]
  def change
    create_table :hangouts do |t|
      # Immutable creator reference — ownership never transfers
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.string   :title,         null: false
      t.text     :description,   null: true

      # 0=virtual, 1=in_person, 2=hybrid
      t.integer  :hangout_type,  null: false, default: 0

      t.string   :location,      null: true
      t.string   :meeting_url,   null: true

      t.datetime :starts_at,     null: false
      t.datetime :ends_at,       null: true

      # Capacity governance — nil means unlimited
      t.integer  :max_attendees, null: true

      # Visibility gate: true = members must be explicitly invited
      t.boolean  :invite_only,   null: false, default: true

      # 0=draft, 1=published, 2=cancelled, 3=completed
      t.integer  :status,        null: false, default: 0

      t.timestamps null: false
    end

    add_index :hangouts, :starts_at
    add_index :hangouts, :status
    add_index :hangouts, [ :creator_id, :status ]
  end
end
