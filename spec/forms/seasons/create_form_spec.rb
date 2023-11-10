# frozen_string_literal: true

describe Seasons::CreateForm, type: :service do
  subject(:form) { instance.call(params: params) }

  let!(:instance) { described_class.new }
  let!(:league) { create :league }
  let!(:season) { create :season, league: league, active: true }

  context 'for invalid params' do
    let(:params) { { name: '', active: true, league_id: league.id } }

    it 'does not create Season', :aggregate_failures do
      expect { form }.not_to change(Season, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'New', active: true, league_id: league.id } }

    it 'creates Season', :aggregate_failures do
      expect { form }.to change(league.seasons, :count).by(1)
      expect(form[:errors]).to be_blank
      expect(season.reload.active).to be_falsy
    end
  end
end
