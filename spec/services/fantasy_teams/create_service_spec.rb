# frozen_string_literal: true

describe FantasyTeams::CreateService, type: :service do
  subject(:service_call) { described_class.call(season: leagues_season, user: user) }

  let!(:leagues_season) { create :leagues_season, active: true }
  let!(:user) { create :user }
  let!(:fantasy_league) {
    create :fantasy_league, leagueable: leagues_season, leagues_season: leagues_season, name: 'Overall'
  }

  context 'for existed fantasy team' do
    let!(:fantasy_team) { create :fantasy_team, user: user }

    before do
      create :fantasy_leagues_team, fantasy_league: fantasy_league, fantasy_team: fantasy_team
    end

    it 'does not create new fantasy team' do
      expect { service_call }.not_to change(FantasyTeam, :count)
    end

    it 'and it fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for not existed fantasy team' do
    it 'creates new fantasy team' do
      expect { service_call }.to change(user.fantasy_teams, :count).by(1)
    end

    it 'and it belongs to league active season' do
      service_call

      expect(leagues_season.league.active_season.fantasy_teams.exists?(user: user)).to be_truthy
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
