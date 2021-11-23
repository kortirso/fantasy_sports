# frozen_string_literal: true

describe FantasyTeams::UpdateService, type: :service do
  subject(:service_call) { described_class.new(transfers_validator: transfers_validator).call(fantasy_team: fantasy_team, params: params) }

  let!(:fantasy_team) { create :fantasy_team }
  let!(:teams_player) { create :teams_player }
  let(:params) { { name: name, teams_players_ids: [teams_player.id] } }
  let(:transfers_validator) { double }

  context 'for invalid params' do
    let(:name) { '' }

    it 'does not update fantasy team' do
      service_call

      expect(fantasy_team.reload.name).not_to eq name
    end

    it 'and does not create fantasy team players' do
      expect { service_call }.not_to change(FantasyTeams::Player, :count)
    end

    it 'and it fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for invalid teams_players_ids params' do
    let(:name) { 'My new team' }

    before do
      allow(transfers_validator).to receive(:call).and_return(['Some error'])
    end

    it 'does not update fantasy team' do
      service_call

      expect(fantasy_team.reload.name).not_to eq name
    end

    it 'and does not create fantasy team players' do
      expect { service_call }.not_to change(FantasyTeams::Player, :count)
    end

    it 'and it fails' do
      service = service_call

      expect(service.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:name) { 'My new team' }

    before do
      allow(transfers_validator).to receive(:call).and_return([])
    end

    it 'updates fantasy team' do
      service_call

      expect(fantasy_team.reload.name).to eq name
    end

    it 'and creates fantasy team players' do
      expect { service_call }.to change(FantasyTeams::Player, :count).by(1)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
