# frozen_string_literal: true

describe Teams::Players::CorrectPricesJob, type: :service do
  subject(:job_call) { described_class.perform_now(week_id: week_id) }

  let!(:league) { create :league, name: { en: 'NBA' } }
  let!(:season) { create :season, league: league }
  let!(:week) { create :week, season: season }
  let!(:lineup) { create :lineup, week: week }
  let!(:players_season1) { create :players_season, average_points: 60 }
  let!(:teams_player1) { create :teams_player, players_season: players_season1, price_cents: 400 }
  let!(:players_season2) { create :players_season, average_points: 60 }
  let!(:teams_player2) { create :teams_player, players_season: players_season2, price_cents: 1_600 }
  let!(:players_season3) { create :players_season, average_points: 10 }
  let!(:teams_player3) { create :teams_player, players_season: players_season3, price_cents: 950 }

  before do
    create :lineups_player, lineup: lineup, teams_player: teams_player1
    create :lineups_player, lineup: lineup, teams_player: teams_player2
    create :lineups_player, lineup: lineup, teams_player: teams_player3
  end

  context 'for unexisting week' do
    let(:week_id) { 'unexisting' }

    it 'does not update teams players', :aggregate_failures do
      job_call

      expect(teams_player1.reload.price_cents).to eq 400
      expect(teams_player2.reload.price_cents).to eq 1_600
      expect(teams_player3.reload.price_cents).to eq 950
    end
  end

  context 'for existing week' do
    let(:week_id) { week.id }

    context 'for disabled league' do
      before { league.update!(name: { en: 'WNBA' }) }

      it 'does not update teams players', :aggregate_failures do
        job_call

        expect(teams_player1.reload.price_cents).to eq 400
        expect(teams_player2.reload.price_cents).to eq 1_600
        expect(teams_player3.reload.price_cents).to eq 950
      end
    end

    context 'for cheap players' do
      it 'updates teams players', :aggregate_failures do
        job_call

        expect(teams_player1.reload.price_cents).to eq 500
        expect(teams_player2.reload.price_cents).to eq 1_600
        expect(teams_player3.reload.price_cents).to eq 950
      end
    end

    context 'for expensive players' do
      before do
        teams_player1.update!(price_cents: 1_600)
        teams_player3.update!(price_cents: 1_100)
      end

      it 'updates teams players', :aggregate_failures do
        job_call

        expect(teams_player1.reload.price_cents).to eq 1_600
        expect(teams_player2.reload.price_cents).to eq 1_600
        expect(teams_player3.reload.price_cents).to eq 1_050
      end
    end
  end
end
