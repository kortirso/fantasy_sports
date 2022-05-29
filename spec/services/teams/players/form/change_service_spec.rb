# frozen_string_literal: true

describe Teams::Players::Form::ChangeService, type: :service do
  subject(:service_call) { described_class.call(games_ids: Game.all.ids, seasons_teams_ids: seasons_teams_ids) }

  let!(:game1) { create :game }
  let!(:game2) { create :game }
  let!(:teams_player1) { create :teams_player, form: 0 }
  let!(:teams_player2) { create :teams_player, form: 0 }
  let!(:teams_player3) { create :teams_player, form: 0 }

  before do
    create :games_player, game: game1, teams_player: teams_player1, points: 2
    create :games_player, game: game2, teams_player: teams_player1, points: 5
    create :games_player, game: game1, teams_player: teams_player2, points: 17
  end

  context 'for all season teams' do
    let(:seasons_teams_ids) { [] }

    it 'updates teams players form', :aggregate_failures do
      service_call

      expect(teams_player1.reload.form).to eq 3.5
      expect(teams_player2.reload.form).to eq 17
      expect(teams_player3.reload.form).to eq 0
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end

  context 'for specific season teams' do
    let(:seasons_teams_ids) { [teams_player1.seasons_team_id] }

    it 'updates teams players form for specific teams', :aggregate_failures do
      service_call

      expect(teams_player1.reload.form).to eq 3.5
      expect(teams_player2.reload.form).to eq 0
      expect(teams_player3.reload.form).to eq 0
    end

    it 'succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end
end
