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

  describe "GET /weather/historical" do
    context "when weather data exists" do
      before do
        24.times do |i|
          time = (Time.now - i.hours).utc.beginning_of_hour
          temperature = rand(15..24)

          create(:weather_data, recorded_at: time, temperature: temperature)
        end
      end

      it "returns the historical weather data" do
        weather = WeatherData.first
        get "/api/weather/historical"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body).count).to eq(24)
        expect(JSON.parse(response.body)[0]).to eq({"time" => weather.recorded_at.iso8601(3), "temperature" => weather.temperature})
      end
    end

    context "when weather data does not exist" do
      it "creates a new weather data records" do
        now = Time.now.utc.beginning_of_hour
        historical_data = 24.times.map do |i|
          {
            time: (now - i.hours).to_s,
            temperature: rand(15.0..24.0).round(1)
          }
        end
        weather_client = instance_double(WeatherClient)
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:historical).and_return(historical_data)

        get "/api/weather/historical"

        expect(response.status).to eq 200
        expect(WeatherData.count).to eq(24)

        response_body = JSON.parse(response.body)
        expect(response_body.first).to eq({"recorded_at" => DateFormatter.format_date(historical_data[0][:time]).iso8601(3), "temperature" => historical_data[0][:temperature]})
      end
    end

    context "when there is an error" do
      it "returns an error response" do
        weather_client = instance_double(WeatherClient, historical: {temperature: 25, time: Time.now.to_s})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:historical).and_raise(WeatherClientError.new("Internal error", 500))

        get "/api/weather/historical"

        expect(response.status).to eq 500
        expect(JSON.parse(response.body)).to eq({"error" => "Internal error: Internal error"})
      end
    end
  end

  describe "GET /weather/historical/max" do
    context "when weather data exists" do
      before do
        24.times do |i|
          time = (Time.now - i.hours).utc.beginning_of_hour
          temperature = 10 + i

          create(:weather_data, recorded_at: time, temperature: temperature)
        end
      end
      it "returns max temerature for 24 hours" do
        get "/api/weather/historical/max"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq 33.0
      end
    end

    context "when weather data does not exist" do
      it "creates request" do
        weather_client = instance_double(WeatherClient, max: {temperature: 25.0})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        get "/api/weather/historical/max"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)["temperature"]).to eq 25.0
      end
    end

    context "when there is an error" do
      it "returns an error response" do
        weather_client = instance_double(WeatherClient, max: {temperature: 25.0})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:max).and_raise(WeatherClientError.new("Internal error", 500))

        get "/api/weather/historical/max"

        expect(response.status).to eq 500
        expect(JSON.parse(response.body)).to eq({"error" => "Internal error: Internal error"})
      end
    end
  end

  describe "GET /weather/historical/min" do
    context "when weather data exists" do
      before do
        24.times do |i|
          time = (Time.now - i.hours).utc.beginning_of_hour
          temperature = 10 + i

          create(:weather_data, recorded_at: time, temperature: temperature)
        end
      end
      it "returns min temerature for 24 hours" do
        get "/api/weather/historical/min"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq 10.0
      end
    end

    context "when weather data does not exist" do
      it "creates request" do
        weather_client = instance_double(WeatherClient, min: {temperature: 10.0})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        get "/api/weather/historical/min"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)["temperature"]).to eq 10.0
      end
    end

    context "when there is an error" do
      it "returns an error response" do
        weather_client = instance_double(WeatherClient, min: {temperature: 10.0})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:min).and_raise(WeatherClientError.new("Internal error", 500))

        get "/api/weather/historical/min"

        expect(response.status).to eq 500
        expect(JSON.parse(response.body)).to eq({"error" => "Internal error: Internal error"})
      end
    end
  end

  describe "GET /weather/historical/avg" do
    context "when weather data exists" do
      before do
        24.times do |i|
          time = (Time.now - i.hours).utc.beginning_of_hour
          temperature = 10 + i

          create(:weather_data, recorded_at: time, temperature: temperature)
        end
      end
      it "returns average temerature for 24 hours" do
        get "/api/weather/historical/avg"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq 21.5
      end
    end

    context "when weather data does not exist" do
      it "creates request" do
        now = Time.now.utc.beginning_of_hour
        historical_data = 24.times.map do |i|
          {
            time: (now - i.hours).to_s,
            temperature: 10 + i
          }
        end
        weather_client = instance_double(WeatherClient)
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:historical).and_return(historical_data)

        get "/api/weather/historical/avg"

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq 21.5
      end
    end

    context "when there is an error" do
      it "returns an error response" do
        weather_client = instance_double(WeatherClient, historical: {temperature: 20.0})
        allow(WeatherClient).to receive(:new).and_return(weather_client)
        allow(weather_client).to receive(:historical).and_raise(WeatherClientError.new("Internal error", 500))

        get "/api/weather/historical/avg"

        expect(response.status).to eq 500
        expect(JSON.parse(response.body)).to eq({"error" => "Internal error: Internal error"})
      end
    end
  end
end
