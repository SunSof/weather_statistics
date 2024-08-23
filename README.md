# Weather Statistics

## Requirements

- Ruby version 3.1.2
- Rails 7.1.3
- PostgreSQL 

## Installation

1. Clone the repository: [`git clone https://github.com/SunSof/weather_statistics.git`]
2. Install dependencies: `bundle install`
3. Setup database: `bundle exec rake db:create` `bundle exec rake db:migrate`
4. Add .env file with `ACCUWEATHER_API_KEY="you_accuweather_key"`

## Running

Start the server and worker: `foreman start`

## Testing

Run tests with RSpec: `rspec spec`
