# frozen_string_literal: true

describe Oraculs::Lineups::Points::UpdateJob, type: :service do
  subject(:job_call) {
    described_class.perform_now(periodable_id: periodable.id, periodable_type: periodable.class.name)
  }

  let!(:league) { create :league }
  let!(:season) { create :season, league: league }
  let!(:week) { create :week, season: season }
  let!(:oracul_place) { create :oracul_place, placeable: season }
  let!(:oracul_league) { create :oracul_league, oracul_place: oracul_place }

  before do
    allow(FantasySports::Container.resolve('services.oraculs.lineups.points.update')).to receive(:call)
    allow(FantasySports::Container.resolve('services.oracul_leagues.members.update_current_place')).to receive(:call)
  end

  context 'for week' do
    let(:periodable) { week }

    it 'calls services', :aggregate_failures do
      job_call

      expect(FantasySports::Container.resolve('services.oraculs.lineups.points.update')).to(
        have_received(:call).with(periodable_id: week.id, periodable_type: 'Week')
      )
      expect(FantasySports::Container.resolve('services.oracul_leagues.members.update_current_place')).to(
        have_received(:call).with(oracul_league: oracul_league)
      )
    end
  end

  context 'for cups round' do
    let!(:cup) { create :cup, league: league }
    let!(:cups_round) { create :cups_round, cup: cup }
    let(:periodable) { cups_round }

    before { oracul_place.update!(placeable: cup) }

    it 'calls services', :aggregate_failures do
      job_call

      expect(FantasySports::Container.resolve('services.oraculs.lineups.points.update')).to(
        have_received(:call).with(periodable_id: cups_round.id, periodable_type: 'Cups::Round')
      )
      expect(FantasySports::Container.resolve('services.oracul_leagues.members.update_current_place')).to(
        have_received(:call).with(oracul_league: oracul_league)
      )
    end
  end
end
