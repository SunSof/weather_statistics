module DateFormatter
  def self.format_date(date_str)
    DateTime.parse(date_str).utc.beginning_of_hour
  end

  def self.valid_unix_timestamp?(value)
    value.is_a?(Integer) && value >= 0 && value <= Time.now.to_i
  end
end
