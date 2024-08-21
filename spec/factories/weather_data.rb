FactoryBot.define do
  factory :weather_data do
    recorded_at { DateFormatter.format_date(Time.now.to_s) }
    temperature { 25 }
  end
end
