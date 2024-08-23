require "rufus-scheduler"

scheduler = Rufus::Scheduler.new

scheduler.cron "59 23 * * *" do
  weather = WeatherClient.new

  begin
    array_with_temperature = weather.historical
    records_to_upsert = array_with_temperature.map do |data|
                          {
                            recorded_at: DateFormatter.format_date(data[:time]),
                            temperature: data[:temperature].to_f
                          }
                        end
      .uniq { |hash| hash[:recorded_at] }
    WeatherData.upsert_all(records_to_upsert, unique_by: :recorded_at)
    Rails.logger.info "Cron job succeeded"
  rescue => e
    Rails.logger.error "Cron job failed: #{e.message}"
  end
end
