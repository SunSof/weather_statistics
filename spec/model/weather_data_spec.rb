require "rails_helper"

RSpec.describe WeatherData, type: :model do
  context "class methods" do
    describe "::for_24_hour" do
      it "returns nil if a db has less instanses than 24" do
        create(:weather_data)

        expect(WeatherData.count).to eq(1)
        expect(WeatherData.for_24_hour).to be_nil
      end

      it "returns array of records if db has at least 24 instanses" do
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

  describe "::closest_by_time" do
    it "returns nil if there is no closest record for the passed day" do
      iso_str = "2024-08-23T13:54:29+00:00"
      date = Time.parse(iso_str)
      create(:weather_data, recorded_at: date - 1.day)

      expect(WeatherData.closest_by_time(date)).to be_nil
    end

    it "returns a value if a value exist" do
      iso_str = "2024-08-23T13:54:29+00:00"
      date = Time.parse(iso_str)
      create(:weather_data, recorded_at: date - 2.hours)
      bingo = create(:weather_data, recorded_at: date + 1.hour)

      expect(WeatherData.closest_by_time(date)).to eq(bingo)
    end
  end
end
