class ApplicationController < ActionController::Base
  before_action :set_country

  private

  def set_country
    @country = params[:country] || 'Country1'
  end

  def establish_shard_connection
    case @country
    when 'Country1'
      ShardRecord.connected_to(role: :reading, shard: :country1) do
        yield
      end
    when 'Country2'
      ShardRecord.connected_to(role: :reading, shard: :country1) do
        yield
      end
    else
      ShardRecord.connected_to(role: :reading, shard: :default) do
        yield
      end
    end
  end
end
