# frozen_string_literal: true

describe Games::ImportJob, type: :service do
  subject(:job_call) { described_class.perform_now(game_ids: game_ids, main_external_source: 'source') }

  let!(:game) { create :game }
  let!(:games_player) { create :games_player, game: game }
  let!(:lineup) { create :lineup, week: game.week }

  before do
    create :lineups_player, lineup: lineup, teams_player: games_player.teams_player

    allow(Games::ImportService).to receive(:call)
    allow(Lineups::Players::Points::UpdateJob).to receive(:perform_later)
  end

  context 'for unexisting games' do
    let(:game_ids) { ['unexisting'] }

    it 'does not call service', :aggregate_failures do
      job_call

      expect(Games::ImportService).not_to have_received(:call)
      expect(Lineups::Players::Points::UpdateJob).not_to have_received(:perform_later)
    end
  end

  context 'for existing games' do
    let(:game_ids) { [game.id] }

    it 'calls service', :aggregate_failures do
      job_call

      expect(Games::ImportService).to have_received(:call).with(game: game, main_external_source: 'source')
      expect(Lineups::Players::Points::UpdateJob).to(
        have_received(:perform_later).with(team_player_ids: [games_player.teams_player_id], week_id: game.week_id)
      )
    end
  end
end
