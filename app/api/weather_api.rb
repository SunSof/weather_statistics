class WeatherApi < Grape::API
  format :json

  resource :weather do
    desc "Get current weather"
    get :current do
      weather = WeatherData.find_by(recorded_at: DateTime.now.utc.beginning_of_hour)

      if weather.nil?
        weather = WeatherClient.new
        begin
          current_weather = weather.current
          utc_time = DateFormatter.format_date(current_weather[:time])
          temperature = current_weather[:temperature]
          WeatherData.delay.create(recorded_at: utc_time, temperature: temperature)
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
          records_to_upsert = array_with_temperature.map do |data|
                                {
                                  recorded_at: DateFormatter.format_date(data[:time]),
                                  temperature: data[:temperature].to_f
                                }
                              end
            .uniq { |hash| hash[:recorded_at] }
          WeatherData.delay.upsert_all(records_to_upsert, unique_by: :recorded_at)
          records_to_upsert
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
      weathers = WeatherData.for_24_hour
      if weathers.nil?
        begin
          weather = WeatherClient.new
          weather.max
        rescue WeatherClientError => e
          error!({error: "Internal error: #{e.message}"}, e.status)
        rescue JSON::ParserError
          error!({error: "Internal error"}, 500)
        end
      else
        weathers.map { |data| data[:temperature] }.max
      end
    end

    desc "Get minimum temperature for the last 24 hours"
    get "historical/min" do
      weathers = WeatherData.for_24_hour
      if weathers.nil?
        begin
          weather = WeatherClient.new
          weather.min
        rescue WeatherClientError => e
          error!({error: "Internal error: #{e.message}"}, e.status)
        rescue JSON::ParserError
          error!({error: "Internal error"}, 500)
        end
      else
        weathers.map { |data| data[:temperature] }.min
      end
    end

    desc "Get average temperature for the last 24 hours"
    get "historical/avg" do
      weathers = WeatherData.for_24_hour
      if weathers.nil?
        weather = WeatherClient.new
        begin
          array_with_temperature = weather.historical
          temperatures = array_with_temperature.map do |data|
            {
              temperature: data[:temperature].to_f
            }
          end
          (temperatures.inject(0.0) { |sum, el| sum + el[:temperature] } / temperatures.count).round(1)
        rescue WeatherClientError => e
          error!({error: "Internal error: #{e.message}"}, e.status)
        rescue JSON::ParserError
          error!({error: "Internal error"}, 500)
        end
      else
        (weathers.inject(0.0) { |sum, el| sum + el[:temperature] } / weathers.count).round(1)
      end
    end

    desc "Get closest temperature by passed timestamp"
    params do
      requires :timestamp, type: Integer, allow_blank: false
    end
    get :by_time do
      unless DateFormatter.valid_unix_timestamp?(params[:timestamp])
        error!({error: "Invalid Unix timestamp"}, 400)
      end

      date = Time.at(params[:timestamp]).utc
      closest_by_time = WeatherData.closest_by_time(date)

      if closest_by_time.nil?
        error!({error: "A temperature by close time not found"}, 404)
      else
        {temperature: closest_by_time[:temperature]}
      end
    end
  end

  desc "Get current weather"
  get :health do
    "OK"
  end
end
