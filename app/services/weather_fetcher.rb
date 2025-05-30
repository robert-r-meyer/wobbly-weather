# frozen_string_literal: true

# type: false

# WeatherFetcher is a service class that fetches weather data from the OpenWeatherMap API.
# Cribed off of https://medium.com/@bamnelkarvivek/how-i-made-a-simple-weather-app-in-ruby-on-rails-309cdced25aa
# Thank you for your service
class WeatherFetcher
  include HTTParty

  base_uri "api.openweathermap.org/data/2.5/weather"

  def initialize(api_key)
    @api_key = api_key
  end

  # :reek:UtilityFunction
  def location_cached?(city)
    # Check if the cache exists for a given city
    city = tokenize_city(city)

    cached = Rails.cache.read("weather_location/#{city}").present?
    Rails.logger.info("Cache for #{city} exists: #{cached}")

    cached
  end

  # :reek:FeatureEnvy
  def weather_by_location(city)
    # Fetch weather data for a given city
    city = tokenize_city(city)

    # Fetch weather data from OpenWeatherMap API
    # and store it in the cache for 1 hour
    Rails.cache.fetch("weather_location/#{city}", expires_in: 30.minutes) do
      response = self.class.get("", query: { q: city, appid: @api_key, units: "metric" })
      if response.success?
        response.parsed_response
      else
        Rails.logger.error("Failed to fetch weather data for #{city}: #{response.code} - #{response.message}")
        { "error" => "Unable to fetch weather data for #{city}" }
      end
    end
  end

  private

  # :reek:UtilityFunction
  def tokenize_city(city)
    # Tokenize the city name to extract the relevant parts
    city.split(",").first.strip
  end
end
