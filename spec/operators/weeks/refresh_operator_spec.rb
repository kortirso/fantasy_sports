# frozen_string_literal: true

describe Weeks::RefreshOperator, type: :service do
  subject(:service_call) { described_class.call(week: week) }

  let!(:week) { create :week, status: Week::COMING }

  it 'succeeds' do
    expect(service_call.success?).to be_truthy
  end

  it 'updates status of week' do
    service_call

    expect(week.reload.status).to eq Week::ACTIVE
  end
end
