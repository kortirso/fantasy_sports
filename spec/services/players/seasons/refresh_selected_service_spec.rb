# frozen_string_literal: true

describe Players::Seasons::RefreshSelectedService, type: :service do
  subject(:service_call) { described_class.new.call(season_id: season.id) }

  let!(:season) { create :season }
  let!(:player1) { create :player }
  let!(:players_season1) { create :players_season, season: season, player: player1 }
  let!(:player2) { create :player }
  let!(:players_season2) { create :players_season, season: season, player: player2 }
  let!(:player3) { create :player }
  let!(:players_season3) { create :players_season, season: season, player: player3 }

  before do
    teams_player1 = create :teams_player, player: player1, players_season: players_season1
    teams_player2 = create :teams_player, player: player2, players_season: players_season2
    create :teams_player, player: player3, players_season: players_season3, active: false

    fantasy_team1 = create :fantasy_team, season: season, completed: true
    fantasy_team2 = create :fantasy_team, season: season, completed: true
    create :fantasy_team, season: season, completed: true
    create :fantasy_team, season: season

    create :fantasy_teams_player, fantasy_team: fantasy_team1, teams_player: teams_player1
    create :fantasy_teams_player, fantasy_team: fantasy_team2, teams_player: teams_player1
    create :fantasy_teams_player, fantasy_team: fantasy_team1, teams_player: teams_player2
  end

  it 'updates players seasons', :aggregate_failures do
    service_call

    expect(players_season1.reload.selected_by_teams_ratio).to eq 67
    expect(players_season2.reload.selected_by_teams_ratio).to eq 33
    expect(players_season3.reload.selected_by_teams_ratio).to eq 0
  end
end
