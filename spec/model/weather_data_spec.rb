require "rails_helper"

RSpec.describe WeatherData, type: :model do
  context "class methods" do
    describe "::for_24_hour" do
      it "returns nil if a db is empty" do
        expect(WeatherData.for_24_hour).to be_nil
      end

      it "returns nil if a db has less instanses than 24" do
        create(:weather_data)

        expect(WeatherData.count).to eq(1)
        expect(WeatherData.for_24_hour).to be_nil
      end

      it "returns true if a db has 24 instanses" do
        24.times do |i|
          time = (Time.now - i.hours).utc.beginning_of_hour
          temperature = rand(15..24)

          create(:weather_data, recorded_at: time, temperature: temperature)
        end
        weathers = WeatherData.for_24_hour
        expect(WeatherData.count).to eq(24)
        expect(weathers.first).to have_attributes(
          recorded_at: be_present,
          temperature: a_value_between(15, 24)
        )
      end
    end
  end
end
