require "faraday"
require "json"

class WeatherService < Grape::API
  @@location_key = 298198
  @@api_key = ENV["ACCUWEATHER_API_KEY"]

  def self.current_weather
    conn = Faraday.new(
      url: "http://dataservice.accuweather.com/currentconditions/v1/#{@@location_key}?",
      headers: {"Content-Type" => "application/json"},
      params: {apikey: @@api_key}
    )
    response = conn.get
    if response.status == 200
      data = JSON.parse(response.body)
      current_temperature = data.dig(0, "Temperature", "Metric", "Value")
      puts "Current temperature in Belgrade: #{current_temperature}°C"
    else
      puts "Failed to fetch weather data: #{response.status}"
    end
  end
end
