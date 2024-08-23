class WeatherData < ApplicationRecord
  validates :recorded_at, presence: true
  validates :temperature, presence: true

  def self.for_24_hour
    weather = WeatherData.where(recorded_at: DateTime.now - 24.hour...DateTime.now)
    (weather.count < 24) ? nil : weather
  end

  def self.closest_by_time(timestamp)
    datetime = timestamp.utc? ? timestamp : timestamp.utc

    start_of_day = datetime.beginning_of_day
    end_of_day = datetime.end_of_day

    WeatherData
      .where(recorded_at: start_of_day..end_of_day)
      .order(Arel.sql("ABS(EXTRACT(EPOCH FROM (recorded_at - ?)))", datetime))
      .first
  end
end
