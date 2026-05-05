# frozen_string_literal: true

# Junction table tracking each member's relationship to a hangout.
# Status lifecycle: invited → accepted / declined / waitlisted
class CreateHangoutParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :hangout_participants do |t|
      t.references :hangout, null: false, foreign_key: true
      t.references :user,    null: false, foreign_key: true

      # 0=invited, 1=accepted, 2=declined, 3=waitlisted
      t.integer :status, null: false, default: 0

      # Timestamp when the member responded to the invitation
      t.datetime :responded_at, null: true

      t.timestamps null: false
    end

    # A user can only have one participation record per hangout
    add_index :hangout_participants, [ :hangout_id, :user_id ], unique: true
    add_index :hangout_participants, [ :user_id, :status ]
  end
end
