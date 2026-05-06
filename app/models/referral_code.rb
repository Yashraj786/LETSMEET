class ReferralCode < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  belongs_to :user
  has_many   :invitations, dependent: :nullify

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  validates :token,    presence: true, uniqueness: true
  validates :max_uses, numericality: { greater_than: 0 }

  # ---------------------------------------------------------------------------
  # Scopes — used by User#can_invite? and User#active_referral_code
  # ---------------------------------------------------------------------------
  scope :active,     -> { where(active: true) }
  scope :available,  -> { where("uses_count < max_uses").where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :exhausted,  -> { where("uses_count >= max_uses") }

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  before_validation :generate_token, on: :create

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------

  # True when this code can still accept uses
  def available?
    active? && uses_count < max_uses && !expired?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  # Atomically increment the use counter; returns false if the code is exhausted
  def consume!
    return false unless available?

    increment!(:uses_count)
    update!(active: false) if uses_count >= max_uses
    true
  end

  private

  # Generate a cryptographically random, URL-safe token
  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
end
