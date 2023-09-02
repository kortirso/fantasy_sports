# frozen_string_literal: true

describe Games::Players::Points::Calculate::BasketballService, type: :service do
  subject(:service_call) { described_class.call(statistic: statistic) }

  let(:statistic) { { 'P' => 10, 'REB' => 2, 'BLK' => 4 } }

  it 'returns points' do
    expect(service_call.result).to eq 24.4
  end
end
