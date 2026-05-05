class User < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Devise modules — confirmable requires email verification before first sign-in;
  # trackable provides sign-in analytics; lockable guards against brute-force.
  # ---------------------------------------------------------------------------
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable

  # Role hierarchy — admin has full platform control, member is the default rank
  enum :role, { member: 0, admin: 1 }, prefix: true

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  belongs_to :invited_by, class_name: "User", optional: true

  has_one  :profile,            dependent: :destroy
  has_many :referral_codes,     dependent: :destroy
  has_many :sent_invitations,   class_name: "Invitation", foreign_key: :sender_id, dependent: :destroy
  has_many :created_hangouts,   class_name: "Hangout",    foreign_key: :creator_id, dependent: :destroy
  has_many :hangout_participants, dependent: :destroy
  has_many :hangouts, through: :hangout_participants

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  after_create :build_default_profile

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Returns the member's display name, falling back to email prefix
  def display_name
    profile&.display_name.presence || email.split("@").first
  end

  # Checks whether this user has any active, non-exhausted referral codes
  def can_invite?
    referral_codes.active.available.exists?
  end

  # Returns the best available referral code for sending a new invitation
  def active_referral_code
    referral_codes.active.available.first
  end

  private

  # Auto-create a blank profile so all associations are always present
  def build_default_profile
    create_profile(display_name: email.split("@").first) unless profile
  end
end
