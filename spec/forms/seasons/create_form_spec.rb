# frozen_string_literal: true

describe Seasons::CreateForm, type: :service do
  subject(:form) { instance.call(params: params) }

  let!(:instance) { described_class.new }
  let!(:league) { create :league }

  context 'for invalid params' do
    let(:params) { { name: '', status: Season::ACTIVE, league_id: league.id } }

    it 'does not create season', :aggregate_failures do
      expect { form }.not_to change(Season, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'New', status: Season::ACTIVE, league_id: league.id } }

    it 'creates season', :aggregate_failures do
      expect { form }.to change(league.seasons, :count).by(1)
      expect(form[:errors]).to be_blank
    end
  end
end
