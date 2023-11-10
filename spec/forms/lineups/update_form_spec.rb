# frozen_string_literal: true

describe Lineups::UpdateForm, type: :service do
  subject(:form) { instance.call(lineup: lineup, params: params) }

  let!(:instance) { described_class.new }
  let!(:lineup) { create :lineup, active_chips: [] }

  before do
    lineup.fantasy_team.update(sport_kind: Sportable::FOOTBALL)
  end

  context 'for invalid lineup params' do
    let(:params) { { active_chips: [Chipable::BENCH_BOOST, Chipable::BENCH_BOOST] } }

    it 'does not update lineup', :aggregate_failures do
      expect(form[:errors]).not_to be_blank
      expect(lineup.reload.active_chips).to eq []
    end
  end

  context 'for not new lineup params' do
    let(:params) { { active_chips: [] } }

    it 'does not update lineup', :aggregate_failures do
      expect(form[:errors]).to be_blank
      expect(lineup.reload.active_chips).to eq []
    end
  end

  context 'for invalid active_chips' do
    let(:params) { { active_chips: [Chipable::BENCH_BOOST, Chipable::TRIPLE_CAPTAIN] } }

    it 'does not update lineup', :aggregate_failures do
      expect(form[:errors]).not_to be_blank
      expect(lineup.reload.active_chips).to eq []
    end
  end

  context 'for not enough available chips' do
    let(:params) { { active_chips: [Chipable::TRIPLE_CAPTAIN] } }

    before do
      lineup.fantasy_team.update(available_chips: { Chipable::TRIPLE_CAPTAIN => 0 })
    end

    it 'does not update lineup', :aggregate_failures do
      expect(form[:errors]).not_to be_blank
      expect(lineup.reload.active_chips).to eq []
    end
  end

  context 'for enough available chips' do
    let(:params) { { active_chips: [Chipable::TRIPLE_CAPTAIN] } }

    before do
      lineup.fantasy_team.update(available_chips: { Chipable::TRIPLE_CAPTAIN => 1 })
    end

    it 'updates lineup and fantasy team', :aggregate_failures do
      expect(form[:errors]).to be_blank
      expect(lineup.reload.active_chips).to eq [Chipable::TRIPLE_CAPTAIN]
      expect(lineup.fantasy_team.reload.available_chips).to eq({ Chipable::TRIPLE_CAPTAIN => 0 })
    end
  end

  context 'for removing chips' do
    let(:params) { { active_chips: [] } }

    before do
      lineup.update(active_chips: [Chipable::TRIPLE_CAPTAIN])
      lineup.fantasy_team.update(available_chips: { Chipable::TRIPLE_CAPTAIN => 0 })
    end

    it 'updates lineup and fantasy team', :aggregate_failures do
      expect(form[:errors]).to be_blank
      expect(lineup.reload.active_chips).to eq []
      expect(lineup.fantasy_team.reload.available_chips).to eq({ Chipable::TRIPLE_CAPTAIN => 1 })
    end
  end
end
