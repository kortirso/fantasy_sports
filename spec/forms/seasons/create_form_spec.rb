# frozen_string_literal: true

describe Seasons::CreateForm, type: :service do
  subject(:service_call) { described_class.call(params: params) }

  let!(:league) { create :league }
  let!(:season) { create :season, league: league, active: true }

  context 'for invalid params' do
    let(:params) { { name: '', active: true, league_id: league.id } }

    it 'does not create Season', :aggregate_failures do
      expect { service_call }.not_to change(Season, :count)
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'New', active: true, league_id: league.id } }

    it 'creates Season', :aggregate_failures do
      expect { service_call }.to change(league.seasons, :count).by(1)
      expect(service_call.success?).to be_truthy
      expect(season.reload.active).to be_falsy
    end
  end
end
