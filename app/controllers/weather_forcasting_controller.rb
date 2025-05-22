# frozen_string_literal: true

# typed: false

class WeatherForcastingController < ApplicationController
    def index
      # Default to New York if no location is provided
      location = params[:location] || "New York"

      # Fetch api key from environment variable for security
      api_key = ENV["WEATHER_API_KEY"]
      api = WeatherFetcher.new(api_key)

      # Fetch weather data for the given location
      city_forcast = api.weather_by_location(location)

      # Determine if the location is cached
      @cached_location = api.location_cached?(location)

      # Handle error if the API call fails
      @forecast = city_forcast unless city_forcast["error"]
    end
end
