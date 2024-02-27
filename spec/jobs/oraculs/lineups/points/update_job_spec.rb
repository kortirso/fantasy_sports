# frozen_string_literal: true

describe Oraculs::Lineups::Points::UpdateJob, type: :service do
  subject(:job_call) { described_class.perform_now(week_id: week.id) }

  let!(:season) { create :season }
  let!(:week) { create :week, season: season }
  let!(:oracul_place) { create :oracul_place, placeable: season }
  let!(:oracul_league) { create :oracul_league, oracul_place: oracul_place }

  before do
    allow(FantasySports::Container.resolve('services.oraculs.lineups.points.update')).to receive(:call)
    allow(FantasySports::Container.resolve('services.oracul_leagues.members.update_current_place')).to receive(:call)
  end

  it 'calls services', :aggregate_failures do
    job_call

    expect(FantasySports::Container.resolve('services.oraculs.lineups.points.update')).to(
      have_received(:call).with(week_id: week.id)
    )
    expect(FantasySports::Container.resolve('services.oracul_leagues.members.update_current_place')).to(
      have_received(:call).with(oracul_league: oracul_league)
    )
  end
end
