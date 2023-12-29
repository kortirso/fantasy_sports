# frozen_string_literal: true

describe Players::Seasons::MassUpdateJob, type: :service do
  subject(:job_call) { described_class.perform_now(season_id: season_id, player_ids: player_ids) }

  let(:season_id) { 'id' }
  let(:player_ids) { 'id' }

  before do
    allow(Players::Seasons::MassUpdateService).to receive(:call)
  end

  it 'calls service' do
    job_call

    expect(Players::Seasons::MassUpdateService).to have_received(:call)
  end
end
