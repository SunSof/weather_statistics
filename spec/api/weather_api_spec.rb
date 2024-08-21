require "rails_helper"

describe WeatherApi do
  describe "GET /weather/current" do
    context "when weather data exists" do
      it "returns the current weather data" do
        weather_data = create(:weather_data)

        get "/api/weather/current"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq({"time" => weather_data.recorded_at.iso8601(3), "temperature" => weather_data.temperature})
      end
    end

    context "when weather data does not exist" do
      it "creates a new weather data record" do
        now = Time.now
        weather_client = instance_double(WeatherClient, current: {temperature: 25, time: now.to_s})
        allow(WeatherClient).to receive(:new).and_return(weather_client)

        get "/api/weather/current"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq({"time" => DateFormatter.format_date(now.to_s).iso8601(3), "temperature" => 25})
        expect(WeatherData.count).to eq 1
      end
    end

    context "when there is an error" do
      it "returns an error response" do
        weather_client = instance_double(WeatherClient, current: {temperature: 25, time: Time.now.to_s})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:current).and_raise(WeatherClientError.new("Internal error", 500))

        get "/api/weather/current"

        expect(response.status).to eq 500
        expect(JSON.parse(response.body)).to eq({"error" => "Internal error: Internal error"})
      end
    end
  end
end
