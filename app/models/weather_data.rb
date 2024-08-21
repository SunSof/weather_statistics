class WeatherData < ApplicationRecord
  before_validation :round_recorded_at_to_hour
  before_validation :convert_to_utc

  validates :recorded_at, presence: true
  validates :temperature, presence: true

  private

  def round_recorded_at_to_hour
    self.recorded_at = recorded_at.change(min: 0, sec: 0) if recorded_at.present?
  end

  def convert_to_utc
    self.recorded_at = recorded_at.utc if recorded_at.present?
  end
end
