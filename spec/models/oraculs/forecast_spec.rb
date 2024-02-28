# frozen_string_literal: true

describe Oraculs::Forecast do
  it 'factory should be valid' do
    oraculs_forecast = build :oraculs_forecast

    expect(oraculs_forecast).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:oraculs_lineup).class_name('::Oraculs::Lineup') }
    it { is_expected.to belong_to(:forecastable) }
  end
end
