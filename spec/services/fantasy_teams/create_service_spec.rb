# frozen_string_literal: true

describe FantasyTeams::CreateService, type: :service do
  subject(:service_call) { described_class.call(season: season, user: user) }

  let!(:season) { create :season, active: true }
  let!(:user) { create :user }
  let!(:fantasy_league) { create :fantasy_league, leagueable: season, season: season, name: 'Overall' }

  before { allow(FantasyTeams::CreateJob).to receive(:perform_later) }

  context 'for existing fantasy team' do
    let!(:fantasy_team) { create :fantasy_team, user: user, season: season }

    before do
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
    end

    it 'does not create new fantasy team', :aggregate_failures do
      expect { service_call }.not_to change(FantasyTeam, :count)
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for not existing fantasy team' do
    it 'creates new fantasy team', :aggregate_failures do
      expect { service_call }.to change(user.fantasy_teams, :count).by(1)
      expect(service_call.success?).to be_truthy
      expect(season.league.active_season.fantasy_teams.exists?(user: user)).to be_truthy
      expect(FantasyTeams::CreateJob).to have_received(:perform_later).with(id: FantasyTeam.last.id)
    end
  end
end
