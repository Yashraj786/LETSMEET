class Hangout < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  belongs_to :creator, class_name: "User"

  has_many :hangout_participants, dependent: :destroy
  has_many :participants,         through: :hangout_participants, source: :user

  # High-res cover imagery for the hangout listing card
  has_one_attached :cover_image

  # ---------------------------------------------------------------------------
  # Enums
  # ---------------------------------------------------------------------------
  enum :hangout_type, { virtual: 0, in_person: 1, hybrid: 2 }
  enum :status,       { draft: 0, published: 1, cancelled: 2, completed: 3 }

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  validates :title,       presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :starts_at,   presence: true
  validate  :ends_after_starts, if: -> { starts_at.present? && ends_at.present? }
  validate  :capacity_is_positive, if: -> { max_attendees.present? }

  validates :cover_image,
            content_type: { in: %w[image/jpeg image/png image/webp], message: "must be JPEG, PNG, or WebP" },
            size: { less_than: 20.megabytes, message: "must be under 20 MB" },
            allow_blank: true

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------
  scope :upcoming,   -> { published.where("starts_at > ?", Time.current).order(:starts_at) }
  scope :past,       -> { published.where("starts_at <= ?", Time.current).order(starts_at: :desc) }
  scope :open_seats, -> { where("max_attendees IS NULL OR max_attendees > (SELECT COUNT(*) FROM hangout_participants WHERE hangout_participants.hangout_id = hangouts.id AND status = 1)") }

  # ---------------------------------------------------------------------------
  # Instance helpers
  # ---------------------------------------------------------------------------

  def accepted_count
    hangout_participants.where(status: :accepted).count
  end

  def seats_remaining
    return nil if max_attendees.nil?
    [ max_attendees - accepted_count, 0 ].max
  end

  def full?
    max_attendees.present? && seats_remaining == 0
  end

  private

  def ends_after_starts
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end

  def capacity_is_positive
    errors.add(:max_attendees, "must be greater than 0") if max_attendees < 1
  end
end
