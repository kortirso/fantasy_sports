# frozen_string_literal: true

describe Players::FindBestService, type: :service do
  subject(:service_call) { described_class.new.call(season: season, week_uuid: week_uuid) }

  let!(:league) { create :league, sport_kind: 'basketball' }
  let!(:season) { create :season, league: league }
  let!(:week) { create :week, season: season }
  let!(:game) { create :game, week: week }

  let!(:player) { create :player, position_kind: 'basketball_center' }
  let!(:teams_player) { create :teams_player, player: player }
  let!(:games_player) { create :games_player, game: game, teams_player: teams_player, points: 23 }

  let(:week_uuid) { week.uuid }

  it 'returns result' do
    expect(service_call).to eq({
      ids: [teams_player.id],
      output: [
        [teams_player.id, games_player.points]
      ]
    })
  end
end
