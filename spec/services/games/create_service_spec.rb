# frozen_string_literal: true

describe Games::CreateService, type: :service do
  subject(:service_call) { described_class.call(params: params) }

  let(:params) {
    {
      week_id: week.id,
      home_season_team_id: season_team1.id,
      visitor_season_team_id: season_team2.id
    }
  }

  context 'for valid params' do
    let!(:week) { create :week, status: 'coming' }
    let!(:season_team1) { create :seasons_team }
    let!(:season_team2) { create :seasons_team }

    before do
      create_list :teams_player, 4, seasons_team: season_team1
      create_list :teams_player, 5, seasons_team: season_team2
    end

    it 'creates Game and Games::Player', :aggregate_failures do
      expect { service_call }.to(
        change(week.games, :count).by(1)
          .and(change(Games::Player, :count).by(9))
      )
      expect(service_call.success?).to be_truthy
    end

    context 'when week is not coming' do
      before { week.update!(status: 'inactive') }

      define_negated_matcher :not_change, :change

      it 'creates Game, but not Games::Player', :aggregate_failures do
        expect { service_call }.to(
          change(week.games, :count).by(1)
            .and(not_change(Games::Player, :count))
        )
        expect(service_call.success?).to be_truthy
      end
    end
  end
end
