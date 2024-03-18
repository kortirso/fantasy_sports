# frozen_string_literal: true

RSpec.describe Oraculs::ForecastSerializer do
  subject(:serializer) do
    described_class.new(
      oraculs_forecast,
      params: {
        owner: owner,
        forecastables: oraculs_lineup.periodable.games.to_a,
        include_fields: %w[id owner value forecastable_id]
      }
    ).serializable_hash
  end

  let(:owner) { false }
  let!(:week) { create :week }
  let!(:game) { create :game, week: week, start_at: 3.hours.after }
  let!(:oraculs_lineup) { create :oraculs_lineup, periodable: week }
  let!(:oraculs_forecast) { create :oraculs_forecast, forecastable: game, value: [3, 1] }

  it 'serializer does not contain value', :aggregate_failures do
    expect(serializer.dig(:data, :attributes, :owner)).to be_falsy
    expect(serializer.dig(:data, :attributes, :value)).to be_empty
  end

  context 'for owner' do
    let(:owner) { true }

    it 'serializer contains value', :aggregate_failures do
      expect(serializer.dig(:data, :attributes, :owner)).to be_truthy
      expect(serializer.dig(:data, :attributes, :value)).to eq([3, 1])
    end
  end

  context 'for unpredictable' do
    before { game.update!(start_at: 1.hour.after) }

    it 'serializer contains value', :aggregate_failures do
      expect(serializer.dig(:data, :attributes, :owner)).to be_falsy
      expect(serializer.dig(:data, :attributes, :value)).to eq([3, 1])
    end
  end
end
