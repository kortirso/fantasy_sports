# frozen_string_literal: true

describe Oraculs::Lineups::Points::UpdateService, type: :service do
  subject(:service_call) { described_class.new.call(week_id: week.id) }

  let!(:week) { create :week }
  let!(:oraculs_lineup) { create :oraculs_lineup, periodable: week }

  before do
    game1 = create :game, week: week, points: [1, 0]
    game2 = create :game, week: week, points: [1, 0]
    game3 = create :game, week: week, points: [1, 0]

    create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game1, value: [1, 0]
    create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game2, value: [2, 0]
    create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game3, value: [0, 3]
  end

  it 'updates points' do
    service_call

    expect(oraculs_lineup.reload.points).to eq 4
  end
end
