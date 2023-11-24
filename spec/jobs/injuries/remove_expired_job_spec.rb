# frozen_string_literal: true

describe Injuries::RemoveExpiredJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:injury1) { create :injury, return_at: nil }
  let!(:injury2) { create :injury, return_at: 1.day.before }
  let!(:injury3) { create :injury, return_at: 1.day.after }

  it 'destroys expired injuries', :aggregate_failures do
    expect { job_call }.to change(Injury, :count).by(-1)

    ids = Injury.pluck(:id)

    expect(ids).to contain_exactly(injury1.id, injury3.id)
    expect(ids).not_to contain_exactly(injury2.id)
  end
end
