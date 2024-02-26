# frozen_string_literal: true

describe FantasyCups::CreateService, type: :service do
  subject(:service_call) {
    described_class
      .new(max_rounds_amount: max_rounds_amount)
      .call(fantasy_league: fantasy_league)
  }

  let(:max_rounds_amount) { 10 }
  let!(:season) { create :season }
  let!(:fantasy_league) { create :fantasy_league, leagueable: season, season: season }

  before do
    [4, 5, 6].each do |week_position|
      create :week, position: week_position, season: season
    end
  end

  context 'when cup exists' do
    before { create :fantasy_cup, fantasy_league: fantasy_league }

    it 'does not create new cup', :aggregate_failures do
      expect { service_call }.not_to change(FantasyCup, :count)
      expect(service_call.success?).to be_truthy
    end
  end

  context 'when cup does not exist' do
    context 'for valid data' do
      before do
        create_list :fantasy_team, 5

        FantasyTeam.find_each do |fantasy_team|
          create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
        end
      end

      it 'creates new cup and creates 2 rounds', :aggregate_failures do
        expect { service_call }.to change(fantasy_league, :fantasy_cup).from(nil)
        expect(service_call.success?).to be_truthy

        rounds = FantasyCup.last.fantasy_cups_rounds.includes(:week).order(position: :desc)

        expect(rounds.size).to eq 2
        rounds.each_with_index do |round, index|
          expect(round.week.position).to eq 5 + index
          expect(round.position).to eq 2 - index
          expect(round.name).to eq FantasyCups::CreateService::ROUND_VALUES[2 - index][:name]
        end
      end

      context 'when max round amount is limited' do
        let(:max_rounds_amount) { 1 }

        it 'creates new cup', :aggregate_failures do
          expect { service_call }.to change(fantasy_league, :fantasy_cup).from(nil)
          expect(service_call.success?).to be_truthy

          rounds = FantasyCup.last.fantasy_cups_rounds.order(position: :desc)
          round = rounds.first

          expect(rounds.size).to eq 1
          expect(round.week.position).to eq 6
          expect(round.position).to eq 1
          expect(round.name).to eq FantasyCups::CreateService::ROUND_VALUES[1][:name]
        end
      end
    end

    context 'for invalid data' do
      it 'creates new cup', :aggregate_failures do
        expect { service_call }.to change(fantasy_league, :fantasy_cup).from(nil)
        expect(service_call.success?).to be_truthy

        rounds = FantasyCup.last.fantasy_cups_rounds

        expect(rounds.size).to eq 0
      end
    end
  end
end
