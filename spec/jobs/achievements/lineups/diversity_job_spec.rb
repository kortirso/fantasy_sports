# frozen_string_literal: true

describe Achievements::Lineups::DiversityJob, type: :service do
  subject(:job_call) { described_class.perform_now(week_id: week_id) }

  let!(:league) { create :league, sport_kind: Sportable::BASKETBALL }
  let!(:season) { create :season, league: league }
  let!(:week) { create :week, season: season }
  let!(:fantasy_team) { create :fantasy_team }
  let!(:lineup) { create :lineup, points: 140, fantasy_team: fantasy_team, week: week }
  let!(:seasons_team1) { create :seasons_team, season: season }
  let!(:seasons_team2) { create :seasons_team, season: season }
  let!(:teams_player1) { create :teams_player, shirt_number_string: '1', seasons_team: seasons_team1 }
  let!(:teams_player2) { create :teams_player, shirt_number_string: '3', seasons_team: seasons_team1 }
  let(:sport) { double }
  let(:max_team_players) { 2 }
  let(:max_players) { 10 }

  before do
    create :lineups_player, lineup: lineup, teams_player: teams_player1
    create :lineups_player, lineup: lineup, teams_player: teams_player2

    allow(Achievement).to receive(:award)
    allow(Sport).to receive(:find_by).and_return(sport)
    allow(sport).to receive_messages(max_team_players: max_team_players, max_players: max_players)
  end

  context 'with unexisting week' do
    let(:week_id) { 'unexisting' }

    it 'does not award lineups' do
      job_call

      expect(Achievement).not_to have_received(:award)
    end
  end

  context 'with existing week' do
    let(:week_id) { week.id }

    it 'awards lineups' do
      job_call

      expect(Achievement).not_to have_received(:award)
    end

    context 'for no_one_team_players' do
      before { teams_player2.update!(seasons_team: seasons_team2) }

      it 'awards lineups' do
        job_call

        expect(Achievement).to have_received(:award).with(:no_one_team_players, fantasy_team.user)
      end
    end

    context 'for team_of_friends' do
      let(:max_players) { 2 }

      it 'awards lineups' do
        job_call

        expect(Achievement).to have_received(:award).with(:team_of_friends, fantasy_team.user)
      end
    end

    context 'for team_of_twins' do
      before { teams_player2.update!(shirt_number_string: '1') }

      it 'awards lineups' do
        job_call

        expect(Achievement).to have_received(:award).with(:team_of_twins, fantasy_team.user)
      end
    end

    context 'for straight_players' do
      let(:max_players) { 2 }

      before { teams_player2.update!(shirt_number_string: '2') }

      it 'awards lineups' do
        job_call

        expect(Achievement).to have_received(:award).with(:straight_players, fantasy_team.user)
      end
    end
  end
end
