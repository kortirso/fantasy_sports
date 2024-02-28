# frozen_string_literal: true

describe OraculLeagues::Members::CurrentPlaceUpdateService, type: :service do
  subject(:service_call) { instance.call(oracul_league: oracul_league) }

  let!(:instance) { described_class.new }
  let!(:oracul_league) { create :oracul_league }

  let!(:oracul1) { create :oracul, points: 1 }
  let!(:oracul2) { create :oracul, points: 3 }
  let!(:oracul3) { create :oracul, points: 2 }
  let!(:oracul_leagues_member1) {
    create :oracul_leagues_member, oracul_league: oracul_league, oracul: oracul1, current_place: 1
  }
  let!(:oracul_leagues_member2) {
    create :oracul_leagues_member, oracul_league: oracul_league, oracul: oracul2, current_place: 1
  }
  let!(:oracul_leagues_member3) {
    create :oracul_leagues_member, oracul_league: oracul_league, oracul: oracul3, current_place: 1
  }

  it 'updates current places', :aggregate_failures do
    service_call

    expect(oracul_leagues_member1.reload.current_place).to eq 3
    expect(oracul_leagues_member2.reload.current_place).to eq 1
    expect(oracul_leagues_member3.reload.current_place).to eq 2
  end
end
