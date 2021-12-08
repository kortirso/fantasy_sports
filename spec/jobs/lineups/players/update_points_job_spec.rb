# frozen_string_literal: true

describe Lineups::Players::UpdatePointsJob, type: :service do
  subject(:job_call) { described_class.perform_now(teams_players_points: teams_players_points, week_id: week.id) }

  let(:week) { create :week }
  let(:teams_player) { create :teams_player }
  let(:teams_players_points) { { teams_player.id.to_s => 5 }.to_json }

  before do
    allow(Lineups::Players::UpdatePointsService).to receive(:call)
  end

  it 'calls notification service' do
    job_call

    expect(Lineups::Players::UpdatePointsService).to have_received(:call).with(
      teams_players_points: { teams_player.id.to_s => 5 },
      week_id:              week.id
    )
  end
end
