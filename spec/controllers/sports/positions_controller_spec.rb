# frozen_string_literal: true

describe Sports::PositionsController, type: :controller do
  describe 'GET#index' do
    let!(:season) { create :season, active: true }
    let!(:sport) { season.league.sport }

    context 'without additional params' do
      before do
        create_list :sports_position, 2, sport: sport

        get :index, params: { sport_id: sport.id, locale: 'en' }
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
        create_list :sports_position, 2, sport: sport

        get :index, params: { sport_id: sport.id, fields: 'min_game_amount,max_game_amount', locale: 'en' }
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
