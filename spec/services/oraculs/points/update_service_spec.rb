# frozen_string_literal: true

describe Oraculs::Points::UpdateService, type: :service do
  subject(:service_call) { described_class.new.call(oracul_ids: oracul_ids) }

  let!(:oracul) { create :oracul }
  let(:oracul_ids) { [oracul.id] }

  before do
    create :oraculs_lineup, oracul: oracul, points: 4
    create :oraculs_lineup, oracul: oracul, points: 2
    create :oraculs_lineup, oracul: oracul, points: 1
  end

  it 'updates oracul points' do
    service_call

    expect(oracul.reload.points).to eq 7
  end
end
