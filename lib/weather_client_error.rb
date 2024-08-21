class WeatherClientError < StandardError
  attr_reader :status, :response_body

  def initialize(message, status = nil)
    super(message)
    @status = status
  end
end
