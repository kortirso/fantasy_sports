# frozen_string_literal: true

describe FantasyTeams::Transfers::PerformService, type: :service do
  subject(:service_call) {
    described_class.new(
      transfers_validator: transfers_validator
    ).call(fantasy_team: fantasy_team, teams_players_ids: [teams_player1.id], only_validate: only_validate)
  }

  let!(:fantasy_team) { create :fantasy_team, free_transfers: 2, transfers_limited: true, budget_cents: 100 }
  let!(:teams_player1) { create :teams_player, price_cents: 400 }
  let!(:teams_player2) { create :teams_player, price_cents: 500 }
  let!(:season) { create :season }
  let!(:week) { create :week, season: season, status: Week::COMING }
  let!(:lineup) { create :lineup, fantasy_team: fantasy_team, week: week }
  let!(:lineups_player) { create :lineups_player, lineup: lineup, teams_player: teams_player2 }
  let(:transfers_validator) { double }

  before do
    create :fantasy_teams_player, fantasy_team: fantasy_team, teams_player: teams_player2

    fantasy_league = create :fantasy_league, season: season
    create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
  end

  context 'for only validation' do
    let(:only_validate) { true }

    context 'for invalid teams_players_ids params' do
      before do
        allow(transfers_validator).to receive(:call).and_return(['Some error'])
      end

      it 'does not update fantasy team' do
        expect { service_call }.not_to change(fantasy_team.reload, :updated_at)
      end

      it 'does not create transfers' do
        expect { service_call }.not_to change(Transfer, :count)
      end

      it 'fails' do
        service = service_call

        expect(service.failure?).to be_truthy
      end
    end

    context 'for valid params' do
      before do
        allow(transfers_validator).to receive(:call).and_return([])
      end

      context 'for over-limited amount of transfers' do
        before do
          fantasy_team.update(free_transfers: 0)
        end

        it 'does not update fantasy team', :aggregate_failures do
          service_call

          expect(fantasy_team.reload.budget_cents).to eq 100
          expect(fantasy_team.reload.free_transfers).to eq 0
        end

        it 'does not update lineup', :aggregate_failures do
          service_call

          expect(lineup.lineups_players.size).to eq 1
          expect(lineup.lineups_players.first.id).to eq lineups_player.id
          expect(lineup.lineups_players.first.teams_player_id).to eq teams_player2.id
        end

        it 'does not create transfers' do
          expect { service_call }.not_to change(Transfer, :count)
        end

        it 'returns validation result' do
          service = service_call

          expect(service.result).to eq({
            out_names:      [teams_player2.player.name],
            in_names:       [teams_player1.player.name],
            points_penalty: 4
          })
        end

        it 'succeed' do
          service = service_call

          expect(service.success?).to be_truthy
        end
      end

      context 'for not over-limited amount of transfers' do
        it 'does not update fantasy team', :aggregate_failures do
          service_call

          expect(fantasy_team.reload.budget_cents).to eq 100
          expect(fantasy_team.reload.free_transfers).to eq 2
        end

        it 'does not update lineup', :aggregate_failures do
          service_call

          expect(lineup.lineups_players.size).to eq 1
          expect(lineup.lineups_players.first.id).to eq lineups_player.id
          expect(lineup.lineups_players.first.teams_player_id).to eq teams_player2.id
        end

        it 'does not create transfers' do
          expect { service_call }.not_to change(Transfer, :count)
        end

        it 'returns validation result' do
          service = service_call

          expect(service.result).to eq({
            out_names:      [teams_player2.player.name],
            in_names:       [teams_player1.player.name],
            points_penalty: 0
          })
        end

        it 'succeed' do
          service = service_call

          expect(service.success?).to be_truthy
        end
      end
    end
  end

  context 'for full transfers' do
    let(:only_validate) { false }

    context 'for invalid teams_players_ids params' do
      before do
        allow(transfers_validator).to receive(:call).and_return(['Some error'])
      end

      it 'does not update fantasy team' do
        expect { service_call }.not_to change(fantasy_team.reload, :updated_at)
      end

      it 'does not create transfers' do
        expect { service_call }.not_to change(Transfer, :count)
      end

      it 'fails' do
        service = service_call

        expect(service.failure?).to be_truthy
      end
    end

    context 'for valid params' do
      before do
        allow(transfers_validator).to receive(:call).and_return([])
      end

      it 'updates fantasy team', :aggregate_failures do
        service_call

        expect(fantasy_team.reload.budget_cents).to eq 200
        expect(fantasy_team.reload.free_transfers).to eq 1
      end

      it 'updates lineup', :aggregate_failures do
        service_call

        expect(lineup.lineups_players.size).to eq 1
        expect(lineup.lineups_players.first.id).not_to eq lineups_player.id
        expect(lineup.lineups_players.first.teams_player_id).to eq teams_player1.id
      end

      it 'creates IN transfer' do
        expect { service_call }.to change(Transfer.in, :count).by(1)
      end

      it 'creates OUT transfer' do
        expect { service_call }.to change(Transfer.out, :count).by(1)
      end

      it 'does not remove players' do
        expect { service_call }.not_to change(Player, :count)
      end

      it 'succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
