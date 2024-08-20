class WeatherApi < Grape::API
  format :json

  resource :weather do
    desc "Get current weather for a location"
    get :current do
      current_temperature = WeatherService.current_weather
      {temperature: "#{current_temperature}°C"}
    rescue => e
      error!({error: e.message}, 500)
    end
  end
end
