# frozen_string_literal: true

describe Weeks::BenchSubstitutionsService, type: :service do
  subject(:service_call) {
    described_class.new(bench_substitutions_service: bench_substitutions_service).call(week: week)
  }

  let(:bench_substitutions_service) { double }
  let!(:week) { create :week }

  before do
    allow(bench_substitutions_service).to receive(:call)
    allow(Lineups::Players::Points::UpdateJob).to receive(:perform_later)
  end

  context 'for week of sport without changes' do
    before { week.season.league.update!(sport_kind: Sportable::BASKETBALL) }

    it 'does not call services' do
      service_call

      expect(bench_substitutions_service).not_to have_received(:call)
    end
  end

  context 'for week of sport with changes' do
    let!(:lineup) { create :lineup, final_points: true, week: week }

    before { week.season.league.update!(sport_kind: Sportable::FOOTBALL) }

    context 'without lineups' do
      it 'does not call services' do
        service_call

        expect(bench_substitutions_service).not_to have_received(:call)
      end
    end

    context 'with lineup' do
      before { lineup.update!(final_points: false) }

      it 'calls services', :aggregate_failures do
        service_call

        expect(bench_substitutions_service).to have_received(:call).with(lineup: lineup)
        expect(Lineups::Players::Points::UpdateJob).to(
          have_received(:perform_later).with(
            team_player_ids: [],
            week_id: week.id,
            final_points: true
          )
        )
      end
    end
  end
end
