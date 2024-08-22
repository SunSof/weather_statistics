class WeatherApi < Grape::API
  format :json

  resource :weather do
    desc "Get current weather for a location"
    get :current do
      weather = WeatherData.find_by(recorded_at: DateTime.now.utc.beginning_of_hour)

      if weather.nil?
        weather = WeatherClient.new
        begin
          current_temperature = weather.current
          utc_time = DateFormatter.format_date(current_temperature[:time])
          temperature = current_temperature[:temperature]
          WeatherData.create(recorded_at: utc_time, temperature: temperature)
          {time: utc_time, temperature: temperature}
        rescue WeatherClientError => e
          error!({error: "Internal error: #{e.message}"}, e.status)
        rescue JSON::ParserError
          error!({error: "Internal error"}, 500)
        end
      else
        {time: weather.recorded_at, temperature: weather.temperature}
      end
    end

    desc "Get historical weather data for the last 24 hours"
    get :historical do
      weathers = WeatherData.for_24_hour
      if weathers.nil?
        weather = WeatherClient.new
        begin
          array_with_temperature = weather.historical
          temperatures_to_upsert = array_with_temperature.map do |data|
            {
              recorded_at: DateFormatter.format_date(data[:time]),
              temperature: data[:temperature].to_f
            }
          end
          WeatherData.upsert_all(temperatures_to_upsert.uniq, unique_by: :recorded_at, returning: %w[recorded_at temperature])
        rescue WeatherClientError => e
          error!({error: "Internal error: #{e.message}"}, e.status)
        rescue JSON::ParserError
          error!({error: "Internal error"}, 500)
        end
      else
        weathers.map do |weather|
          {time: weather.recorded_at, temperature: weather.temperature}
        end
      end
    end
    desc "Get maximum temperature for the last 24 hours"
    get "historical/max" do
      weather = WeatherClient.new
      weather.max
    end
  end
end
