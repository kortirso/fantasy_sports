# frozen_string_literal: true

describe Games::Players::Points::Calculate::FootballService, type: :service do
  subject(:service_call) { described_class.call(statistic: statistic, position_kind: Positionable::GOALKEEPER) }

  let(:statistic) { { 'MP' => 61, 'CS' => 1 } }

  it 'returns points' do
    expect(service_call.result).to eq 6
  end
end
