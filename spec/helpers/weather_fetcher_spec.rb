require "rails_helper"

RSpec.describe WeatherFetcher do
  let(:api_key) { "dummy_api_key" }
  let(:city) { "London" }
  let(:fetcher) { WeatherFetcher.new(api_key) }

  describe "#location_cached?" do
    it "returns true if cache exists for the city" do
      Rails.cache.write("weather_location/#{city}", { temp: 10 })
      expect(fetcher.location_cached?(city)).to be true
    end

    it "returns false if cache does not exist for the city" do
      Rails.cache.delete("weather_location/#{city}")
      expect(fetcher.location_cached?(city)).to be false
    end

    it "uses only the city name part if city includes a country" do
      Rails.cache.write("weather_location/#{city}", { temp: 10 })
      expect(fetcher.location_cached?("#{city},GB")).to be true
    end
  end

  describe "#weather_by_location" do
    before do
      Rails.cache.delete("weather_location/#{city}")
    end

    it "fetches weather data from API and caches it if not cached" do
      response = double("HTTParty::Response", success?: true, parsed_response: { "main" => { "temp" => 15 } })
      allow(WeatherFetcher).to receive(:get).and_return(response)

      result = fetcher.weather_by_location(city)
      expect(result["main"]["temp"]).to eq(15)
      expect(Rails.cache.read("weather_location/#{city}")).to eq({ "main" => { "temp" => 15 } })
    end
    it "returns cached data if present and does not call the API" do
      Rails.cache.write("weather_location/#{city}", { "main" => { "temp" => 22 } })
      expect(WeatherFetcher).not_to receive(:get)
      result = fetcher.weather_by_location(city)
      expect(result["main"]["temp"]).to eq(22)
    end

    it "returns error hash if API call fails" do
      response = double("HTTParty::Response", success?: false, code: 404, message: "Not Found")
      allow(WeatherFetcher).to receive(:get).and_return(response)

      result = fetcher.weather_by_location(city)
      expect(result["error"]).to eq("Unable to fetch weather data for #{city}")
    end

    it "caches the API response for 30 minutes" do
      response = double("HTTParty::Response", success?: true, parsed_response: { "main" => { "temp" => 25 } })
      allow(WeatherFetcher).to receive(:get).and_return(response)

      expect(Rails.cache).to receive(:fetch).with("weather_location/#{city}", expires_in: 30.minutes).and_call_original
      fetcher.weather_by_location(city)
    end

    it "handles city names with spaces and country codes" do
      city_with_space = "New York,US"
      city_key = "New York"
      response = double("HTTParty::Response", success?: true, parsed_response: { "main" => { "temp" => 17 } })
      allow(WeatherFetcher).to receive(:get).and_return(response)

      result = fetcher.weather_by_location(city_with_space)
      expect(result["main"]["temp"]).to eq(17)
      expect(Rails.cache.read("weather_location/#{city_key}")).to eq({ "main" => { "temp" => 17 } })
    end

    it "logs an error when API call fails" do
      response = double("HTTParty::Response", success?: false, code: 500, message: "Internal Server Error")
      allow(WeatherFetcher).to receive(:get).and_return(response)
      expect(Rails.logger).to receive(:error).with(/Failed to fetch weather data for #{city}: 500 - Internal Server Error/)
      fetcher.weather_by_location(city)
    end
  end
end
