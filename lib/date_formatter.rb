module DateFormatter
  def self.format_date(date_str)
    DateTime.parse(date_str).utc.beginning_of_hour
  end
end
