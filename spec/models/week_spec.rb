# frozen_string_literal: true

describe Week do
  it 'factory should be valid' do
    week = build :week

    expect(week).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:season) }
    it { is_expected.to have_many(:games).dependent(:destroy) }
    it { is_expected.to have_many(:games_players).through(:games) }
    it { is_expected.to have_many(:fantasy_leagues).dependent(:destroy) }
    it { is_expected.to have_many(:lineups).dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_teams).through(:lineups) }
    it { is_expected.to have_many(:teams_players).through(:lineups) }
    it { is_expected.to have_many(:oraculs_lineups).class_name('::Oraculs::Lineup').dependent(:destroy) }
  end
end
