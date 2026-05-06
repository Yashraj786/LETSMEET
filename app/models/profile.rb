class Profile < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  belongs_to :user

  # ActiveStorage — high-res media handled server-side with variant generation
  has_one_attached :avatar
  has_one_attached :cover_photo

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  validates :display_name, presence: true, length: { maximum: 80 }
  validates :bio,          length: { maximum: 500 }, allow_blank: true
  validates :website,      format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" },
                           allow_blank: true

  validates :avatar,
            content_type: { in: %w[image/jpeg image/png image/webp], message: "must be JPEG, PNG, or WebP" },
            size: { less_than: 10.megabytes, message: "must be under 10 MB" }

  validates :cover_photo,
            content_type: { in: %w[image/jpeg image/png image/webp], message: "must be JPEG, PNG, or WebP" },
            size: { less_than: 25.megabytes, message: "must be under 25 MB" }

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------
  scope :public_profiles, -> { where(public_profile: true) }
  scope :by_interest,     ->(interest) { where("? = ANY(interests)", interest) }
end
