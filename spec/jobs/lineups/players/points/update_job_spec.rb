# frozen_string_literal: true

describe Lineups::Players::Points::UpdateJob, type: :service do
  subject(:job_call) { described_class.perform_now(team_player_ids: team_player_ids, week_id: week.id) }

  let!(:season) { create :season }
  let!(:week) { create :week, season: season }
  let!(:teams_player) { create :teams_player }
  let!(:fantasy_league) { create :fantasy_league, season: season, leagueable: season }
  let(:team_player_ids) { [teams_player.id] }

  before do
    allow(Lineups::Players::Points::UpdateService).to receive(:call)
    allow(FantasySports::Container.resolve('services.fantasy_leagues.teams.update_current_place')).to receive(:call)
  end

  it 'calls notification service', :aggregate_failures do
    job_call

    expect(Lineups::Players::Points::UpdateService).to have_received(:call).with(
      team_player_ids: [teams_player.id],
      week_id: week.id,
      final_points: false
    )
    expect(FantasySports::Container.resolve('services.fantasy_leagues.teams.update_current_place')).to(
      have_received(:call).with(fantasy_league: fantasy_league)
    )
  end
end
