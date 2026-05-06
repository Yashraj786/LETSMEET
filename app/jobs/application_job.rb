class ApplicationJob < ActiveJob::Base
  # Retry transient failures (network, DB deadlocks) with exponential back-off
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  # If the underlying record is gone (e.g. user deleted), silently discard
  discard_on ActiveJob::DeserializationError
end
