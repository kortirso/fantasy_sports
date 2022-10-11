# frozen_string_literal: true

describe Lineups::Players::Points::UpdateJob, type: :service do
  subject(:job_call) { described_class.perform_now(team_player_ids: team_player_ids, week_id: week.id) }

  let(:week) { create :week }
  let(:teams_player) { create :teams_player }
  let(:team_player_ids) { [teams_player.id] }

  before do
    allow(Lineups::Players::Points::UpdateService).to receive(:call)
  end

  it 'calls notification service' do
    job_call

    expect(Lineups::Players::Points::UpdateService).to have_received(:call).with(
      team_player_ids: [teams_player.id],
      week_id:         week.id
    )
  end
end
