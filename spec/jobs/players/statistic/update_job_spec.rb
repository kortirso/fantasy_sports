# frozen_string_literal: true

describe Players::Statistic::UpdateJob, type: :service do
  subject(:job_call) { described_class.perform_now(season_id: season.id, player_ids: []) }

  let!(:season) { create :season }

  before do
    allow(Players::Statistic::UpdateService).to receive(:call)
  end

  it 'calls service' do
    job_call

    expect(Players::Statistic::UpdateService).to have_received(:call).with(
      season_id:  season.id,
      player_ids: []
    )
  end
end
