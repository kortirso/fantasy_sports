# frozen_string_literal: true

describe Injuries::ImportJob do
  subject(:job_call) { described_class.perform_now(import_service: import_service) }

  let!(:season1) { create :season, active: true }
  let!(:season2) { create :season, active: false }
  let(:import_service) { instance_double(Injuries::ImportService, call: nil) }

  it 'imports injuries', :aggregate_failures do
    job_call

    expect(import_service).to have_received(:call).with(season: season1)
    expect(import_service).not_to have_received(:call).with(season: season2)
  end
end
