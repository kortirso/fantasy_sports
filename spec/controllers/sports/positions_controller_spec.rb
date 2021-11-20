# frozen_string_literal: true

describe Sports::PositionsController, type: :controller do
  describe 'GET#index' do
    let!(:league) { create :league }

    context 'without additional params' do
      before do
        create_list :sports_position, 2, sport: league.sport

        get :index, params: { league_id: league.id }
      end

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name total_amount].each do |attr|
        it "and contains team #{attr}" do
          expect(response.body).to have_json_path("sports_positions/data/0/attributes/#{attr}")
        end
      end

      %w[min_game_amount max_game_amount].each do |attr|
        it "and contains team #{attr}" do
          expect(response.body).not_to have_json_path("sports_positions/data/0/attributes/#{attr}")
        end
      end
    end

    context 'with additional params' do
      before do
        create_list :sports_position, 2, sport: league.sport

        get :index, params: { league_id: league.id, fields: 'min_game_amount,max_game_amount' }
      end

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name total_amount min_game_amount max_game_amount].each do |attr|
        it "and contains team #{attr}" do
          expect(response.body).to have_json_path("sports_positions/data/0/attributes/#{attr}")
        end
      end
    end
  end
end
