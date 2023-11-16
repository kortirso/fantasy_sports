# frozen_string_literal: true

describe Lineups::BenchSubstitutionsService, type: :service do
  subject(:service_call) { described_class.call(lineup: lineup) }

  let!(:lineup) { create :lineup }

  # rubocop: disable Layout/LineLength, RSpec/LetSetup
  let!(:goalies) { create_list :player, 2, position_kind: Positionable::GOALKEEPER }
  let!(:defenders) { create_list :player, 5, position_kind: Positionable::GOALKEEPER }
  let!(:mids) { create_list :player, 5, position_kind: Positionable::GOALKEEPER }
  let!(:forwards) { create_list :player, 3, position_kind: Positionable::GOALKEEPER }

  let!(:teams_players) { Player.all.map { |player| create(:teams_player, player: player) } }
  let!(:lineups_player1) { create(:lineups_player, lineup: lineup, teams_player: teams_players[0], change_order: 0, statistic: { 'MP' => 0 }) }
  let!(:lineups_player2) { create(:lineups_player, lineup: lineup, teams_player: teams_players[1], change_order: 1, statistic: { 'MP' => 1 }) }
  let!(:lineups_player3) { create(:lineups_player, lineup: lineup, teams_player: teams_players[2], change_order: 0, statistic: { 'MP' => 1 }) }
  let!(:lineups_player4) { create(:lineups_player, lineup: lineup, teams_player: teams_players[3], change_order: 0, statistic: { 'MP' => 1 }) }
  let!(:lineups_player5) { create(:lineups_player, lineup: lineup, teams_player: teams_players[4], change_order: 0, statistic: { 'MP' => 1 }) }
  let!(:lineups_player6) { create(:lineups_player, lineup: lineup, teams_player: teams_players[5], change_order: 2, statistic: { 'MP' => 0 }) }
  let!(:lineups_player7) { create(:lineups_player, lineup: lineup, teams_player: teams_players[6], change_order: 3, statistic: { 'MP' => 0 }) }
  let!(:lineups_player8) { create(:lineups_player, lineup: lineup, teams_player: teams_players[7], change_order: 0, statistic: { 'MP' => 1 }) }
  let!(:lineups_player9) { create(:lineups_player, lineup: lineup, teams_player: teams_players[8], change_order: 0, statistic: { 'MP' => 1 }) }
  let!(:lineups_player10) { create(:lineups_player, lineup: lineup, teams_player: teams_players[9], change_order: 0, statistic: { 'MP' => 1 }) }
  let(:lineups_player11) { create(:lineups_player, lineup: lineup, teams_player: teams_players[10], change_order: 0, statistic: { 'MP' => 1 }) }
  let!(:lineups_player12) { create(:lineups_player, lineup: lineup, teams_player: teams_players[11], change_order: 4, statistic: { 'MP' => 0 }) }
  let!(:lineups_player13) { create(:lineups_player, lineup: lineup, teams_player: teams_players[12], change_order: 0, statistic: { 'MP' => 0 }, status: Lineups::Player::CAPTAIN) }
  let!(:lineups_player14) { create(:lineups_player, lineup: lineup, teams_player: teams_players[13], change_order: 0, statistic: { 'MP' => 1 }, status: Lineups::Player::ASSISTANT) }
  let!(:lineups_player15) { create(:lineups_player, lineup: lineup, teams_player: teams_players[14], change_order: 0, statistic: { 'MP' => 1 }) }
  # rubocop: enable Layout/LineLength, RSpec/LetSetup

  it 'updates change order of players', :aggregate_failures do
    expect(service_call.success?).to be_truthy
    expect(lineups_player1.reload.change_order).to eq 1
    expect(lineups_player2.reload.change_order).to eq 0
    expect(lineups_player13.reload.status).to eq Lineups::Player::ASSISTANT
    expect(lineups_player14.reload.status).to eq Lineups::Player::CAPTAIN
  end
end
