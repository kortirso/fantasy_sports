# frozen_string_literal: true

describe Games::CreateService, type: :service do
  subject(:service_call) {
    described_class.call(
      week_id: week.id,
      home_season_team_id: season_team1.id,
      visitor_season_team_id: season_team2.id
    )
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
      expect { service_call }.to change(week.games, :count).by(1)
    end

    it 'creates game players' do
      expect { service_call }.to change(Games::Player, :count).by(9)
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
