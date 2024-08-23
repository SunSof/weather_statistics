require "rails_helper"

RSpec.describe WeatherClient, type: :request do
  describe "#current" do
    it "returns hash when status 200" do
      VCR.use_cassette "current/response_200" do
        result = WeatherClient.new.current
        expect(result[:temperature]).to eq 27.4
        expect(result[:time]).to eq "2024-08-20T20:57:00+02:00"
      end
    end

    it "raises WeatherClientError when bad response" do
      VCR.use_cassette "current/bad_response" do
        client = WeatherClient.new
        expect { client.current }.to raise_error do |error|
          expect(error).to be_a(WeatherClientError)
          expect(error.message).to eq("Can't get weather info")
          expect(error.status).to eq 400
        end
      end
    end

    it "raises JSON::ParserError when invalid json" do
      VCR.use_cassette "current/bad_json_parse" do
        client = WeatherClient.new
        expect { client.current }.to raise_error(JSON::ParserError)
      end
    end

    it "raises WeatherClientError when value not found" do
      VCR.use_cassette "current/value_not_found" do
        client = WeatherClient.new
        expect { client.current }.to raise_error do |error|
          expect(error).to be_a(WeatherClientError)
          expect(error.message).to eq("Value not found")
          expect(error.status).to eq 500
        end
      end
    end
  end

  describe "#historical" do
    it "returns array of hashes when status 200" do
      VCR.use_cassette "historical/response_200" do
        client = WeatherClient.new

        result = client.historical

        expect(result).to be_a Array
        expect(result.first).to be_a Hash
        expect(result.first).to eq({temperature: "23.0°C", time: "2024-08-20T23:02:00+02:00"})
      end
    end

    it "raises WeatherClientError when values not found" do
      VCR.use_cassette "historical/value_not_found" do
        client = WeatherClient.new
        expect { client.historical }.to raise_error do |error|
          expect(error).to be_a(WeatherClientError)
          expect(error.message).to eq("Value not found")
          expect(error.status).to eq 500
        end
      end
    end
  end

  describe "#max" do
    it "returns max temperature when status 200" do
      VCR.use_cassette "max_min/response_200" do
        client = WeatherClient.new
        expect(client.max).to eq 30.6
      end
    end

    it "raises WeatherClientError when values not found" do
      VCR.use_cassette "max_min/value_not_found" do
        client = WeatherClient.new
        expect { client.max }.to raise_error do |error|
          expect(error).to be_a(WeatherClientError)
          expect(error.message).to eq("Value not found")
          expect(error.status).to eq 500
        end
      end
    end
  end

  describe "#min" do
    it "returns min temperature when status 200" do
      VCR.use_cassette "max_min/response_200" do
        client = WeatherClient.new
        expect(client.min).to eq 22.1
      end
    end

    it "raises WeatherClientError when values not found" do
      VCR.use_cassette "max_min/value_not_found" do
        client = WeatherClient.new
        expect { client.min }.to raise_error do |error|
          expect(error).to be_a(WeatherClientError)
          expect(error.message).to eq("Value not found")
          expect(error.status).to eq 500
        end
      end
    end
  end
end
