# weather_data_spec.rb

require 'rspec'
require 'webmock/rspec'
require 'csv'
require_relative 'weather_data'

describe WeatherData do
  let(:city) { 'Kyiv' }
  let(:invalid_city) { 'UnknownCity' }
  let(:weather_data) { WeatherData.new(city) }
  let(:weather_data_invalid) { WeatherData.new(invalid_city) }
  let(:api_url) { "https://api.openweathermap.org/data/2.5/weather?q=Kyiv&appid=5ea2f79adfe4ac2649b796212b898107&units=metric" }
  let(:invalid_api_url) { "https://api.openweathermap.org/data/2.5/weather?q=UnknownCity&appid=5ea2f79adfe4ac2649b796212b898107&units=metric" }
  let(:api_response) do
    {
      "cod" => 200,
      "name" => "Kyiv",
      "main" => {
        "temp" => 10.0,
        "humidity" => 75
      },
      "wind" => {
        "speed" => 3.5
      }
    }.to_json
  end

  let(:not_found_response) do
    {
      "cod" => "404",
      "message" => "city not found"
    }.to_json
  end

  before do
    stub_request(:get, api_url).to_return(status: 200, body: api_response)
    stub_request(:get, invalid_api_url).to_return(status: 404, body: not_found_response)
  end

  describe '#fetch_weather_data' do
    it 'makes a successful HTTP request to the API' do
      weather_data.fetch_weather_data
      expect(WebMock).to have_requested(:get, api_url).once
    end

    it 'parses the response correctly' do
      expected_data = {
        city: "Kyiv",
        temperature: 10.0,
        humidity: 75,
        wind_speed: 3.5
      }
      expect(weather_data.send(:extract_weather_data, JSON.parse(api_response))).to eq(expected_data)
    end

    it 'saves weather data to a CSV file' do
      weather_data.fetch_weather_data

      csv_content = CSV.read('weather_data.csv')
      expect(csv_content).to eq([
                                  ["City", "Temperature (C)", "Humidity (%)", "Wind Speed (m/s)"],
                                  ["Kyiv", "10.0", "75", "3.5"]
                                ])
    end

    it 'handles an invalid city gracefully' do
      expect { weather_data_invalid.fetch_weather_data }.to output("City not found: UnknownCity. Please check the name and try again.\n").to_stdout
    end
  end
end
