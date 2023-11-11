# frozen_string_literal: true

describe Games::DifficultyUpdateService, type: :service do
  subject(:service_call) { instance.call(week: week4) }

  let!(:instance) { described_class.new }
  let!(:league) { create :league, points_system: { W: 3, D: 1, L: 0 } }
  let!(:season) { create :season, league: league, members_count: 6 }
  let!(:seasons_team1) { create :seasons_team, season: season }
  let!(:seasons_team2) { create :seasons_team, season: season }
  let!(:seasons_team3) { create :seasons_team, season: season }
  let!(:seasons_team4) { create :seasons_team, season: season }
  let!(:seasons_team5) { create :seasons_team, season: season }
  let!(:seasons_team6) { create :seasons_team, season: season }
  let!(:week1) { create :week, season: season, position: 1, status: Week::FINISHED }
  let!(:week2) { create :week, season: season, position: 2, status: Week::FINISHED }
  let!(:week4) { create :week, season: season, position: 4, status: Week::COMING }
  let!(:week5) { create :week, season: season, position: 5, status: Week::COMING }
  let!(:game1) {
    create :game, week: week1, home_season_team: seasons_team1, visitor_season_team: seasons_team2, points: [2, 0]
  }
  let!(:game2) {
    create :game, week: week1, home_season_team: seasons_team3, visitor_season_team: seasons_team4, points: [1, 0]
  }
  let!(:game3) {
    create :game, week: week2, home_season_team: seasons_team1, visitor_season_team: seasons_team4, points: [3, 1]
  }
  let!(:game4) {
    create :game, week: week2, home_season_team: seasons_team2, visitor_season_team: seasons_team3, points: [1, 1]
  }
  let!(:game5) {
    create :game, week: week4, home_season_team: seasons_team2, visitor_season_team: seasons_team1, points: []
  }
  let!(:game6) {
    create :game, week: week4, home_season_team: seasons_team4, visitor_season_team: seasons_team3, points: []
  }
  let!(:game7) {
    create :game, week: week5, home_season_team: seasons_team4, visitor_season_team: seasons_team1, points: []
  }
  let!(:game8) {
    create :game, week: week5, home_season_team: seasons_team3, visitor_season_team: seasons_team2, points: []
  }

  before { create :game, week: week1, home_season_team: seasons_team5, visitor_season_team: seasons_team6, points: [] }

  it 'updates difficulties', :aggregate_failures do
    service_call

    # points of teams
    # seasons_team1 => 6
    # seasons_team3 => 4
    # seasons_team2 => 1
    # seasons_team4 => 0
    # seasons_team5 => nil
    # seasons_team6 => nil

    # does not update old games
    expect(game1.reload.difficulty).to eq [3, 3]
    expect(game2.reload.difficulty).to eq [3, 3]
    expect(game3.reload.difficulty).to eq [3, 3]
    expect(game4.reload.difficulty).to eq [3, 3]
    # updates coming games
    expect(game5.reload.difficulty).to eq [5, 3]
    expect(game6.reload.difficulty).to eq [4, 2]
    expect(game7.reload.difficulty).to eq [5, 2]
    expect(game8.reload.difficulty).to eq [3, 4]
  end
end
