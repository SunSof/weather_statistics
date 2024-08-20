require "./lib/weather_client"

RSpec.describe WeatherClient, type: :request do
  context "variable methods" do
    describe "#current" do
      it "returns true if status 200 and results match" do
        VCR.use_cassette "current/response_200" do
          client = WeatherClient.new
          expect(client.current).to eq 27.4
        end
      end
      it "returns error if return bad response" do
        VCR.use_cassette "current/bad_response" do
          client = WeatherClient.new
          expect { client.current }.to raise_error(RuntimeError, "Can't get weather info, status: 400")
        end
      end
      it "returns error if Json can't parse" do
        VCR.use_cassette "current/bad_json_parse" do
          client = WeatherClient.new
          expect { client.current }.to raise_error(JSON::ParserError, "unexpected token at '}]'")
        end
      end
      it "returns error if value not found" do
        VCR.use_cassette "current/value_not_found" do
          client = WeatherClient.new
          expect { client.current }.to raise_error(RuntimeError, "Value not found")
        end
      end
    end
    describe "#historical" do
      it "returns true if status 200 and results match" do
        VCR.use_cassette "historical/response_200" do
          client = WeatherClient.new
          expect(client.historical[0].values).to eq ["23:02", "23.0°C"]
        end
      end
      it "returns error if values not found" do
        VCR.use_cassette "historical/value_not_found" do
          client = WeatherClient.new
          expect { client.historical }.to raise_error(RuntimeError, "Value not found")
        end
      end
    end
    describe "#max" do
      it "returns true if status 200 and results match" do
        VCR.use_cassette "max_min_avg/response_200" do
          client = WeatherClient.new
          expect(client.max).to eq 30.6
        end
      end
      it "returns error if values not found" do
        VCR.use_cassette "max_min_avg/value_not_found" do
          client = WeatherClient.new
          expect { client.max }.to raise_error(RuntimeError, "Value not found")
        end
      end
    end
    describe "#min" do
      it "returns error if values not found" do
        VCR.use_cassette "max_min_avg/response_200" do
          client = WeatherClient.new
          expect(client.min).to eq 22.1
        end
      end
      it "returns error if values not found" do
        VCR.use_cassette "max_min_avg/value_not_found" do
          client = WeatherClient.new
          expect { client.min }.to raise_error(RuntimeError, "Value not found")
        end
      end
    end
  end
end
