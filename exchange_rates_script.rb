require 'net/http'
require 'json'
require 'csv'


api_key = '5cca9dfba1e6524cb9d7c503'


base_currency = 'USD'

# Функція для отримання курсів валют
def get_exchange_rates(api_key, base_currency)
  url = "https://v6.exchangerate-api.com/v6/#{api_key}/latest/#{base_currency}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

# Функція для витягу інформації про курси валют
def extract_currency_info(exchange_data)
  exchange_data['conversion_rates'].map do |currency, rate|
    { currency: currency, rate: rate }
  end
end

# Функція для збереження даних у CSV файл
def save_to_csv(data, file_name)
  CSV.open(file_name, 'w', write_headers: true, headers: ['Валюта', 'Курс']) do |csv|
    data.each do |row|
      csv << [row[:currency], row[:rate]]
    end
  end
end

# Головний код для виконання
exchange_data = get_exchange_rates(api_key, base_currency)
currency_info = extract_currency_info(exchange_data)
save_to_csv(currency_info, 'exchange_rates.csv')

puts "Дані про курси валют збережено у 'exchange_rates.csv'."
