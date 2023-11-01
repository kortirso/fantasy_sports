# frozen_string_literal: true

describe Achievements::Lineups::PointsJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:fantasy_team) { create :fantasy_team, sport_kind: Sportable::BASKETBALL }

  before do
    create :lineup, points: 14, fantasy_team: fantasy_team

    allow(Achievement).to receive(:award)
  end

  it 'awards lineup' do
    job_call

    expect(Achievement).to have_received(:award).with(:basketball_lineup_points, 14, fantasy_team.user)
  end
end
