# frozen_string_literal: true

describe FantasyCups::Pairs::GenerateService, type: :service do
  subject(:service_call) { described_class.call(week: week) }

  let(:max_rounds_amount) { 10 }
  let!(:season) { create :season }
  let!(:fantasy_league) { create :fantasy_league, leagueable: season, season: season }
  let!(:week1) { create :week, position: 4, season: season }
  let!(:week2) { create :week, position: 5, season: season }
  let(:week) { week1 }

  context 'when cup does not exist' do
    it 'does not create new cup pairs', :aggregate_failures do
      expect { service_call }.not_to change(FantasyCups::Pair, :count)
      expect(service_call.success?).to be_truthy
    end
  end

  context 'when cup exists' do
    let!(:cup) { create :fantasy_cup, fantasy_league: fantasy_league }

    context 'when cup round does not exist' do
      it 'does not create new cup pairs', :aggregate_failures do
        expect { service_call }.not_to change(FantasyCups::Pair, :count)
        expect(service_call.success?).to be_truthy
      end
    end

    context 'when cup round exists' do
      let!(:round1) { create :fantasy_cups_round, fantasy_cup: cup, week: week1, position: 3 }
      let!(:team1) { create :fantasy_team, points: 40 }
      let!(:team2) { create :fantasy_team, points: 50 }
      let!(:team3) { create :fantasy_team, points: 25 }
      let!(:team4) { create :fantasy_team, points: 30 }
      let!(:team5) { create :fantasy_team, points: 20 }
      let!(:team6) { create :fantasy_team, points: 150 }
      let!(:team7) { create :fantasy_team, points: 110 }
      let!(:team8) { create :fantasy_team, points: 130 }
      let!(:team9) { create :fantasy_team, points: 12 }
      let!(:lineup1) { create :lineup, fantasy_team: team1, week: week1, points: 40, penalty_points: -4 }
      let!(:lineup2) { create :lineup, fantasy_team: team2, week: week1, points: 40, penalty_points: -4 }
      let!(:lineup3) { create :lineup, fantasy_team: team3, week: week1, points: 30, penalty_points: -4 }
      let!(:lineup4) { create :lineup, fantasy_team: team4, week: week1, points: 10, penalty_points: -4 }
      let!(:lineup5) { create :lineup, fantasy_team: team5, week: week1, points: 20, penalty_points: -4 }
      let!(:lineup6) { create :lineup, fantasy_team: team6, week: week1, points: 40, penalty_points: -4 }
      let!(:lineup7) { create :lineup, fantasy_team: team7, week: week1, points: 30, penalty_points: -4 }
      let!(:lineup8) { create :lineup, fantasy_team: team8, week: week1, points: 10, penalty_points: -4 }

      before do
        FantasyTeam.find_each do |fantasy_team|
          create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
        end
        create :lineup, fantasy_team: team9, week: week1
      end

      context 'when there is no previous round' do
        it 'creates 4 new cup pairs', :aggregate_failures do
          expect { service_call }.to change(round1.fantasy_cups_pairs, :count).by(4)
          expect(service_call.success?).to be_truthy

          pairs = round1.fantasy_cups_pairs.includes(:home_lineup, :visitor_lineup)

          expect(pairs[0].home_lineup).to eq lineup6
          expect(pairs[0].visitor_lineup).to eq lineup5
          expect(pairs[1].home_lineup).to eq lineup8
          expect(pairs[1].visitor_lineup).to eq lineup3
          expect(pairs[2].home_lineup).to eq lineup7
          expect(pairs[2].visitor_lineup).to eq lineup4
          expect(pairs[3].home_lineup).to eq lineup2
          expect(pairs[3].visitor_lineup).to eq lineup1
        end
      end

      context 'when there is previous round' do
        let(:week) { week2 }
        let!(:round2) { create :fantasy_cups_round, fantasy_cup: cup, week: week2, position: 2 }

        before do
          create :fantasy_cups_pair, fantasy_cups_round: round1, home_lineup: lineup6, visitor_lineup: lineup5
          create :fantasy_cups_pair, fantasy_cups_round: round1, home_lineup: lineup8, visitor_lineup: lineup3
          create :fantasy_cups_pair, fantasy_cups_round: round1, home_lineup: lineup7, visitor_lineup: lineup4
          create :fantasy_cups_pair, fantasy_cups_round: round1, home_lineup: lineup2, visitor_lineup: lineup1

          FantasyTeam.find_each do |fantasy_team|
            create :lineup, fantasy_team: fantasy_team, week: week2
          end
        end

        it 'creates 2 new cup pairs', :aggregate_failures do
          expect { service_call }.to change(round2.fantasy_cups_pairs, :count).by(2)
          expect(service_call.success?).to be_truthy

          pair1 = round2.fantasy_cups_pairs

          expect(pair1.first.home_lineup).to eq lineup6.fantasy_team.lineups.find_by(week: week2)
          expect(pair1.first.visitor_lineup).to eq lineup3.fantasy_team.lineups.find_by(week: week2)
          expect(pair1.last.home_lineup).to eq lineup7.fantasy_team.lineups.find_by(week: week2)
          expect(pair1.last.visitor_lineup).to eq lineup2.fantasy_team.lineups.find_by(week: week2)
        end
      end
    end
  end
end
