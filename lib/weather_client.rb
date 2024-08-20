require "faraday"
require "json"

class WeatherClient
  URL = "http://dataservice.accuweather.com/currentconditions/v1/"
  LOCATION_KEY = 298198

  def initialize
    @conn = Faraday.new(url: URL,
      headers: {"Content-Type" => "application/json"},
      params: {apikey: ENV["ACCUWEATHER_API_KEY"]})
  end

  def request(path, details = false)
    response = @conn.get(path, details)
    case response.status
    when 200
      JSON.parse(response.body)
    when 400...600
      raise "Can't get weather info, status: #{response.status}"
    end
  end

  def current
    response = request("#{LOCATION_KEY}")
    data = response.dig(0, "Temperature", "Metric", "Value")
    raise "Value not found" unless data
    data
  end

  def historical
    response = request("#{LOCATION_KEY}/historical/24")
    response.map do |value|
      datetime = value.dig("LocalObservationDateTime")
      temperature = value.dig("Temperature", "Metric", "Value")
      raise "Value not found" unless datetime || temperature
      time = Time.parse(datetime).strftime("%H:%M")
      {time: time, temperature: "#{temperature}°C"}
    end
  end

  def max
    response = request("#{LOCATION_KEY}/historical/24", {details: true})
    data = response.dig(0, "TemperatureSummary", "Past24HourRange", "Maximum", "Metric", "Value")
    raise "Value not found" unless data
    data
  end

  def min
    response = request("#{LOCATION_KEY}/historical/24", {details: true})
    data = response.dig(0, "TemperatureSummary", "Past24HourRange", "Minimum", "Metric", "Value")
    raise "Value not found" unless data
    data
  end
end
