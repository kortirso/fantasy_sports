# frozen_string_literal: true

describe Achievements::Lineups::PointsJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:fantasy_team1) { create :fantasy_team, sport_kind: Sportable::BASKETBALL }
  let!(:fantasy_team2) { create :fantasy_team, sport_kind: Sportable::FOOTBALL }

  before do
    create :lineup, points: 14, fantasy_team: fantasy_team1
    create :lineup, points: 15, fantasy_team: fantasy_team2

    allow(Achievement).to receive(:award)
  end

  it 'awards lineup', :aggregate_failures do
    job_call

    expect(Achievement).to have_received(:award).with(:basketball_lineup_points, 14, fantasy_team1.user)
    expect(Achievement).to have_received(:award).with(:football_lineup_points, 15, fantasy_team2.user)
  end
end
