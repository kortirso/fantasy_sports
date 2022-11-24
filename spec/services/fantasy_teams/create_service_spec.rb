# frozen_string_literal: true

describe FantasyTeams::CreateService, type: :service do
  subject(:service_call) { described_class.call(season: season, user: user) }

  let(:event_store) { Rails.configuration.event_store }
  let!(:season) { create :season, active: true }
  let!(:user) { create :user }
  let!(:fantasy_league) {
    create :fantasy_league, leagueable: season, season: season, name: 'Overall'
  }

  it 'subscribes for events' do
    expect(FantasyTeams::CreateJob).to have_subscribed_to_events(FantasyTeams::CreatedEvent).in(event_store)
  end

  context 'for existing fantasy team' do
    let!(:fantasy_team) { create :fantasy_team, user: user }

    before do
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
    end

    it 'does not create new fantasy team' do
      expect { service_call }.not_to change(FantasyTeam, :count)
    end

    it 'fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for not existing fantasy team' do
    it 'creates new fantasy team' do
      expect { service_call }.to change(user.fantasy_teams, :count).by(1)
    end

    it 'publishes FantasyTeams::CreatedEvent' do
      service_call

      expect(event_store).to(
        have_published(an_event(FantasyTeams::CreatedEvent).with_data(fantasy_team_uuid: FantasyTeam.last.uuid))
      )
    end

    it 'belongs to league active season' do
      service_call

      expect(season.league.active_season.fantasy_teams.exists?(user: user)).to be_truthy
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
