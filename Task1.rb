# weather_data.rb

require 'net/http'
require 'json'
require 'csv'

class WeatherData
  API_URL = 'https://api.openweathermap.org/data/2.5/weather'
  API_KEY = '5ea2f79adfe4ac2649b796212b898107'

  def initialize(city)
    @city = city
  end

  def fetch_weather_data
    uri = URI("#{API_URL}?q=#{@city}&appid=#{API_KEY}&units=metric")
    response = Net::HTTP.get_response(uri)

    case response
    when Net::HTTPSuccess
      parsed_response = JSON.parse(response.body)
      weather_info = extract_weather_data(parsed_response)
      save_to_csv(weather_info)
    when Net::HTTPNotFound
      puts "City not found: #{@city}. Please check the name and try again."
    else
      puts "An error occurred: #{response.message}"
    end
  end

  private

  def extract_weather_data(parsed_response)
    {
      city: parsed_response['name'],
      temperature: parsed_response['main']['temp'],
      humidity: parsed_response['main']['humidity'],
      wind_speed: parsed_response['wind']['speed']
    }
  end

  def save_to_csv(weather_info)
    CSV.open("weather_data.csv", "w") do |csv|
      csv << ["City", "Temperature (C)", "Humidity (%)", "Wind Speed (m/s)"]
      csv << [weather_info[:city], weather_info[:temperature], weather_info[:humidity], weather_info[:wind_speed]]
    end
  end
end
