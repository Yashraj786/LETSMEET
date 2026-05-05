class HangoutParticipant < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  belongs_to :hangout
  belongs_to :user

  # ---------------------------------------------------------------------------
  # Enums
  # ---------------------------------------------------------------------------
  enum :status, { invited: 0, accepted: 1, declined: 2, waitlisted: 3 }

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  validates :hangout_id, uniqueness: { scope: :user_id, message: "already participating in this hangout" }

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  before_save :stamp_response, if: :status_changed?

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------
  scope :attending, -> { where(status: :accepted) }

  private

  # Record when the member made a decision (accept / decline / waitlist)
  def stamp_response
    self.responded_at = Time.current unless invited?
  end
end
