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

    get :historical do
      weather = WeatherData.where(recorded_at: DateTime.now - 24.hour...DateTime.now)
      p weather
      # if weather.nil?
      #   weather = WeatherClient.new
      #   current_temperature = weather.historical
      #   WeatherData.create(recorded_at: current_temperature[:time], temperature: current_temperature[:temperature])
      #   current_temperature
      # end
    end
  end
end
