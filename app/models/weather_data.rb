class WeatherData < ApplicationRecord
  validates :recorded_at, presence: true
  validates :temperature, presence: true

  validate :recorded_at_must_be_on_the_hour

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

  private

  def recorded_at_must_be_on_the_hour
    if recorded_at.present? && (recorded_at.min != 0 || recorded_at.sec != 0)
      errors.add(:recorded_at, "must be on the hour (minutes and seconds must be zero)")
    end
  end
end
