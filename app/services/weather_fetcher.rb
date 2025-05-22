# frozen_string_literal: true

# type: false

class WeatherFetcher
  include HTTParty

  base_uri "api.openweathermap.org/data/2.5/weather"

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_weather(city)
    response = self.class.get("", query: { q: city, appid: @api_key })
    if response.success?
      response.parsed_response
    else
      raise "Error fetching weather data: #{response.message}"
    end
  end
end
