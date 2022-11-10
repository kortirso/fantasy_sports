# frozen_string_literal: true

describe Seasons::CreateService, type: :service do
  subject(:service_call) { described_class.call(params: params) }

  let!(:league) { create :league }
  let!(:season) { create :season, league: league, active: true }

  context 'for invalid params' do
    let(:params) { { name: '', active: true, league_id: league.id } }

    it 'does not create Season' do
      expect { service_call }.not_to change(Season, :count)
    end

    it 'fails' do
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'New', active: true, league_id: league.id } }

    it 'creates Season' do
      expect { service_call }.to change(league.seasons, :count).by(1)
    end

    it 'updates active seasons' do
      service_call

      expect(season.reload.active).to be_falsy
    end

    it 'succeed' do
      expect(service_call.success?).to be_truthy
    end
  end
end
