class Invitation < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  belongs_to :sender,        class_name: "User"
  belongs_to :referral_code

  # ---------------------------------------------------------------------------
  # Enums
  # ---------------------------------------------------------------------------
  enum :status, { pending: 0, accepted: 1, expired: 2, revoked: 3 }

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  validates :recipient_email, presence: true,
                              format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" },
                              uniqueness: { scope: :sender_id, conditions: -> { pending }, message: "already has a pending invitation" }
  validates :token,           presence: true, uniqueness: true
  validates :expires_at,      presence: true

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  before_validation :generate_token, on: :create
  before_validation :set_expiry,     on: :create

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------
  scope :active,   -> { pending.where("expires_at > ?", Time.current) }
  scope :stale,    -> { pending.where("expires_at <= ?", Time.current) }

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------

  def expired_by_time?
    expires_at.present? && expires_at <= Time.current
  end

  # Accept the invitation: mark accepted, record timestamp, and create the user
  # via the supplied block (Devise registration flow handles the actual User creation)
  def accept!
    update!(status: :accepted, accepted_at: Time.current)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  # Invitations are valid for 7 days — enough time, not too permissive
  def set_expiry
    self.expires_at ||= 7.days.from_now
  end
end
