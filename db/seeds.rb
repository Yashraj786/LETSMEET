# frozen_string_literal: true
#
# Seeds the LetsMeet platform with:
#   1. An initial admin user (the "Founder")
#   2. A batch of referral codes for the founder to distribute
#
# Usage: rails db:seed
# Re-runnable: idempotent — won't create duplicates on repeated runs.

puts "🔐 Seeding LetsMeet..."

# ---------------------------------------------------------------------------
# Founder / Admin
# ---------------------------------------------------------------------------
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@letsmeet.app")
admin_password = ENV.fetch("ADMIN_PASSWORD", SecureRandom.hex(16))

admin = User.find_or_initialize_by(email: admin_email)

if admin.new_record?
  admin.assign_attributes(
    password: admin_password,
    password_confirmation: admin_password,
    role: :admin
  )
  # Skip confirmation email for the seeded founder
  admin.skip_confirmation!
  admin.save!
  puts "  ✅ Admin created: #{admin_email} / #{admin_password}"
  puts "  ⚠️  SAVE THIS PASSWORD — it will not be shown again." if ENV["ADMIN_PASSWORD"].blank?
else
  puts "  ℹ️  Admin already exists: #{admin_email}"
end

# ---------------------------------------------------------------------------
# Founder referral codes — 10 codes, each valid for 1 use, no expiry
# ---------------------------------------------------------------------------
if admin.referral_codes.active.count < 10
  codes_needed = 10 - admin.referral_codes.active.count
  codes_needed.times do
    admin.referral_codes.create!(max_uses: 1)
  end
  puts "  ✅ #{codes_needed} referral codes minted for the founder."
else
  puts "  ℹ️  Founder already has #{admin.referral_codes.active.count} active codes."
end

puts "\n🚀 LetsMeet is ready. Admin: #{admin_email}"

#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
