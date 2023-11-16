# frozen_string_literal: true

describe FantasyLeagues::Teams::CurrentPlaceUpdateService, type: :service do
  subject(:service_call) { instance.call(fantasy_league: fantasy_league) }

  let!(:instance) { described_class.new }
  let!(:fantasy_league) { create :fantasy_league }

  context 'for fantasy teams' do
    let!(:fantasy_team1) { create :fantasy_team, points: 1, completed: true }
    let!(:fantasy_team2) { create :fantasy_team, points: 3, completed: true }
    let!(:fantasy_team3) { create :fantasy_team, points: 2, completed: true }
    let!(:fantasy_leagues_team1) {
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team1, current_place: 1
    }
    let!(:fantasy_leagues_team2) {
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team2, current_place: 1
    }
    let!(:fantasy_leagues_team3) {
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team3, current_place: 1
    }

    it 'updates current places', :aggregate_failures do
      service_call

      expect(fantasy_leagues_team1.reload.current_place).to eq 3
      expect(fantasy_leagues_team2.reload.current_place).to eq 1
      expect(fantasy_leagues_team3.reload.current_place).to eq 2
    end
  end

  context 'for lineups' do
    let!(:week) { create :week }
    let!(:lineup1) { create :lineup, week: week, points: 3 }
    let!(:lineup2) { create :lineup, week: week, points: 1 }
    let!(:lineup3) { create :lineup, week: week, points: 2 }
    let!(:fantasy_leagues_team1) {
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: lineup1, current_place: 1
    }
    let!(:fantasy_leagues_team2) {
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: lineup2, current_place: 1
    }
    let!(:fantasy_leagues_team3) {
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: lineup3, current_place: 1
    }

    it 'updates current places', :aggregate_failures do
      fantasy_league.update!(leagueable: week)

      service_call

      expect(fantasy_leagues_team1.reload.current_place).to eq 1
      expect(fantasy_leagues_team2.reload.current_place).to eq 3
      expect(fantasy_leagues_team3.reload.current_place).to eq 2
    end
  end
end
