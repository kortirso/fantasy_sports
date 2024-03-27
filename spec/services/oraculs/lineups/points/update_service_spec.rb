# frozen_string_literal: true

describe Oraculs::Lineups::Points::UpdateService, type: :service do
  subject(:service_call) {
    described_class.new.call(periodable_id: periodable.id, periodable_type: periodable.class.name)
  }

  context 'for week' do
    let!(:periodable) { create :week }
    let!(:oraculs_lineup) { create :oraculs_lineup, periodable: periodable }

    before do
      game1 = create :game, week: periodable, points: [1, 0]
      game2 = create :game, week: periodable, points: [1, 0]
      game3 = create :game, week: periodable, points: [1, 0]

      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game1, value: [1, 0]
      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game2, value: [2, 0]
      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: game3, value: [0, 3]
    end

    it 'updates points' do
      service_call

      expect(oraculs_lineup.reload.points).to eq 4
    end
  end

  context 'for cups round' do
    let!(:periodable) { create :cups_round }
    let!(:oraculs_lineup) { create :oraculs_lineup, periodable: periodable }

    before do
      cups_pair1 = create :cups_pair, cups_round: periodable, points: [1, 0]
      cups_pair2 = create :cups_pair, cups_round: periodable, points: [1, 0]
      cups_pair3 = create :cups_pair, cups_round: periodable, points: [1, 0]

      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair1, value: [1, 0]
      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair2, value: [2, 0]
      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair3, value: [0, 3]
    end

    it 'updates points' do
      service_call

      expect(oraculs_lineup.reload.points).to eq 4
    end
  end

  context 'for cups round with best of elimination' do
    let!(:periodable) { create :cups_round }
    let!(:oraculs_lineup) { create :oraculs_lineup, periodable: periodable }

    before do
      cups_pair1 = create(
        :cups_pair,
        cups_round: periodable,
        elimination_kind: Cups::Pair::BEST_OF,
        required_wins: 2,
        points: [2, 0]
      )
      cups_pair2 = create(
        :cups_pair,
        cups_round: periodable,
        elimination_kind: Cups::Pair::BEST_OF,
        required_wins: 2,
        points: [2, 1]
      )
      cups_pair3 = create(
        :cups_pair,
        cups_round: periodable,
        elimination_kind: Cups::Pair::BEST_OF,
        required_wins: 2,
        points: [1, 0]
      )

      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair1, value: [2, 0]
      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair2, value: [2, 0]
      create :oraculs_forecast, oraculs_lineup: oraculs_lineup, forecastable: cups_pair3, value: [2, 0]
    end

    it 'updates points' do
      service_call

      expect(oraculs_lineup.reload.points).to eq 4
    end
  end
end
