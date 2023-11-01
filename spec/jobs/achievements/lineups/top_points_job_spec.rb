# frozen_string_literal: true

describe Achievements::Lineups::TopPointsJob, type: :service do
  subject(:job_call) { described_class.perform_now(week_id: week_id) }

  let!(:week) { create :week }
  let!(:fantasy_league) { create :fantasy_league, leagueable: week, season: week.season }
  let!(:fantasy_team1) { create :fantasy_team }
  let!(:lineup1) { create :lineup, points: 140, fantasy_team: fantasy_team1, week: week }
  let!(:fantasy_team2) { create :fantasy_team }
  let!(:lineup2) { create :lineup, points: 280, fantasy_team: fantasy_team2, week: week }

  before do
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: lineup1
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: lineup2

    allow(Achievement).to receive(:award)
  end

  context 'with unexisting week' do
    let(:week_id) { 'unexisting' }

    it 'does not award lineups' do
      job_call

      expect(Achievement).not_to have_received(:award)
    end
  end

  context 'with existing week' do
    let(:week_id) { week.id }

    it 'awards lineups', :aggregate_failures do
      job_call

      expect(Achievement).to have_received(:award).with(:basketball_top_lineup, 2, fantasy_team1.user)
      expect(Achievement).to have_received(:award).with(:basketball_top_lineup, 1, fantasy_team2.user)
    end
  end
end
