# frozen_string_literal: true

describe Games::CreateService, type: :service do
  subject(:service_call) {
    described_class.call(week: week, home_season_team: season_team1, visitor_season_team: season_team2)
  }

  context 'for valid params' do
    let(:week) { create :week }
    let(:season_team1) { create :seasons_team }
    let(:season_team2) { create :seasons_team }

    before do
      create_list :teams_player, 4, seasons_team: season_team1
      create_list :teams_player, 5, seasons_team: season_team2
    end

    it 'creates Game' do
      expect { service_call }.to change(Game, :count).by(1)
    end

    it 'and creates game players' do
      expect { service_call }.to change(Games::Player, :count).by(9)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
