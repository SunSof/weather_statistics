class WeatherData < ApplicationRecord
  validates :recorded_at, presence: true
  validates :temperature, presence: true

  def self.for_24_hour
    weather = WeatherData.where(recorded_at: DateTime.now - 24.hour...DateTime.now)
    (weather.count < 24) ? nil : weather
  end

  def self.closest_by_time(timestamp)
    WeatherData.order(Arel.sql("ABS(EXTRACT(EPOCH FROM recorded_at) - #{timestamp})")).first
  end
end
