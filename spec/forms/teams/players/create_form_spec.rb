# frozen_string_literal: true

describe Teams::Players::CreateForm, type: :service do
  subject(:form) { instance.call(params: params) }

  let!(:instance) { described_class.new }
  let!(:seasons_team) { create :seasons_team }
  let!(:player) { create :player }
  let!(:week) { create :week, season: seasons_team.season, status: 'active' }

  before { create :game, week: week, home_season_team: seasons_team }

  context 'for invalid params' do
    let(:params) { { player_id: player.id, seasons_team_id: seasons_team.id, price_cents: 'abs' } }

    it 'does not create teams_player', :aggregate_failures do
      expect { form }.not_to change(Teams::Player, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) {
      {
        player_id: player.id,
        seasons_team_id: seasons_team.id,
        price_cents: 123,
        shirt_number_string: '1'
      }
    }

    it 'creates teams_player and games_player', :aggregate_failures do
      expect { form }.to(
        change(Teams::Player, :count).by(1)
          .and(change(Games::Player, :count).by(1))
      )
      expect(form[:errors]).to be_nil
    end
  end
end
