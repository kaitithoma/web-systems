class ApplicationJob < ActiveJob::Base
  queue_as :default

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  private

  def establish_shard_connection(country)
    case country
    when 'Country1'
      ActiveRecord::Base.connected_to(role: :writing, shard: :country1) do
        yield
      end
    when 'Country2'
      ActiveRecord::Base.connected_to(role: :writing, shard: :country1) do
        yield
      end
    else
      ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
        yield
      end
    end
  end
end
