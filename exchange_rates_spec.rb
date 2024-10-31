require 'rspec'
require 'webmock/rspec'
require 'json'
require 'csv'
require_relative 'exchange_rates_script'

RSpec.describe 'Exchange Rate API' do
  let(:api_key) { '5cca9dfba1e6524cb9d7c503' }
  let(:base_currency) { 'USD' }
  let(:api_url) { "https://v6.exchangerate-api.com/v6/#{api_key}/latest/#{base_currency}" }

  before do
    stub_request(:get, api_url).
      to_return(status: 200, body: {
        "result": "success",
        "conversion_rates": {
          "EUR": 0.84,
          "GBP": 0.75,
          "JPY": 110.0
        }
      }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'HTTP Request' do
    it 'returns a successful response' do
      response = get_exchange_rates(api_key, base_currency)
      expect(response['result']).to eq('success')
    end
  end

  describe 'Data Processing' do
    it 'extracts currency data correctly' do
      response = get_exchange_rates(api_key, base_currency)
      currency_info = extract_currency_info(response)

      expect(currency_info).to be_an(Array)
      expect(currency_info.size).to eq(3)

      expect(currency_info[0]).to include(currency: 'EUR', rate: 0.84)
      expect(currency_info[1]).to include(currency: 'GBP', rate: 0.75)
      expect(currency_info[2]).to include(currency: 'JPY', rate: 110.0)
    end
  end

  describe 'CSV File Saving' do
    let(:file_name) { 'exchange_rates_test.csv' }

    after do
      # Очистка тестового файлу після тесту
      File.delete(file_name) if File.exist?(file_name)
    end

    it 'saves currency data to CSV file' do
      response = get_exchange_rates(api_key, base_currency)
      currency_info = extract_currency_info(response)
      save_to_csv(currency_info, file_name)

      expect(File).to exist(file_name)

      # Перевірка даних у CSV файлі
      csv_data = CSV.read(file_name, headers: true)
      expect(csv_data.size).to eq(3)
      expect(csv_data[0]['Валюта']).to eq('EUR')
      expect(csv_data[0]['Курс']).to eq('0.84')
      expect(csv_data[1]['Валюта']).to eq('GBP')
      expect(csv_data[1]['Курс']).to eq('0.75')
      expect(csv_data[2]['Валюта']).to eq('JPY')
      expect(csv_data[2]['Курс']).to eq('110.0')
    end
  end
end

