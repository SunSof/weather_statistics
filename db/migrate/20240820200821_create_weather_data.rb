class CreateWeatherData < ActiveRecord::Migration[7.1]
  def change
    create_table :weather_data do |t|
      t.timestamp :recorded_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.float :temperature, null: false

      t.timestamps
    end
  end
end
