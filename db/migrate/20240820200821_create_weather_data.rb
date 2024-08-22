class CreateWeatherData < ActiveRecord::Migration[7.1]
  def change
    create_table :weather_data do |t|
      t.timestamp :recorded_at, null: false, index: {unique: true}
      t.float :temperature, null: false
    end
  end
end
