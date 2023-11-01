# frozen_string_literal: true

describe Achievements::RefreshAfterGameJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  before { allow(Achievements::Lineups::PointsJob).to receive(:perform_later) }

  it 'publishes 1 event' do
    job_call

    expect(Achievements::Lineups::PointsJob).to have_received(:perform_later)
  end
end
