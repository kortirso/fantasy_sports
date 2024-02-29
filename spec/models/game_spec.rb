# frozen_string_literal: true

describe Game do
  it 'factory should be valid' do
    game = create :game

    expect(game).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:week).optional }
    it { is_expected.to belong_to(:season) }
    it { is_expected.to belong_to(:home_season_team).class_name('Seasons::Team') }
    it { is_expected.to belong_to(:visitor_season_team).class_name('Seasons::Team') }
    it { is_expected.to have_many(:games_players).class_name('::Games::Player').dependent(:destroy) }
    it { is_expected.to have_many(:teams_players).through(:games_players) }
    it { is_expected.to have_many(:external_sources).class_name('::Games::ExternalSource').dependent(:destroy) }
    it { is_expected.to have_many(:oraculs_forecasts).class_name('::Oraculs::Forecast').dependent(:destroy) }
  end

  describe '#result_for_team' do
    let!(:game) { create :game, points: [] }

    it 'return nils when no points', :aggregate_failures do
      expect(game.result_for_team(0)).to be_nil
      expect(game.result_for_team(1)).to be_nil
    end

    context 'when home team win' do
      before { game.update!(points: [1, 0]) }

      it 'return results', :aggregate_failures do
        expect(game.result_for_team(0)).to eq 'W'
        expect(game.result_for_team(1)).to eq 'L'
      end
    end

    context 'when visitor team win' do
      before { game.update!(points: [1, 2]) }

      it 'return results', :aggregate_failures do
        expect(game.result_for_team(0)).to eq 'L'
        expect(game.result_for_team(1)).to eq 'W'
      end
    end

    context 'when draw' do
      before { game.update!(points: [2, 2]) }

      it 'return results', :aggregate_failures do
        expect(game.result_for_team(0)).to eq 'D'
        expect(game.result_for_team(1)).to eq 'D'
      end
    end
  end
end
