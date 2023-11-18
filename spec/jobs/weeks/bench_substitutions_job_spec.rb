# frozen_string_literal: true

describe Weeks::BenchSubstitutionsJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:week1) { create :week, status: Week::COMING }
  let!(:week2) { create :week, status: Week::ACTIVE }
  let!(:week3) { create :week, status: Week::ACTIVE }
  let!(:week4) { create :week, status: Week::ACTIVE }
  let(:service) { FantasySports::Container.resolve('services.weeks.bench_substitutions') }

  before do
    allow(service).to receive(:call)

    create :game, week: week2, points: []
    create :game, week: week3, points: [1, 2], start_at: 1.hour.before
    create :game, week: week4, points: [1, 2], start_at: 2.days.before
  end

  it 'calls service only for active week with finished games', :aggregate_failures do
    job_call

    expect(service).not_to have_received(:call).with(week: week1)
    expect(service).not_to have_received(:call).with(week: week2)
    expect(service).not_to have_received(:call).with(week: week3)
    expect(service).to have_received(:call).with(week: week4)
  end
end
