# frozen_string_literal: true

describe LineupsController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing lineup' do
        let!(:lineup) { create :lineup }

        before do
          lineup.fantasy_team.update(user: @current_user)

          get :show, params: { id: lineup.uuid, locale: 'en' }
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end

        %w[uuid active_chips fantasy_team].each do |attr|
          it "contains lineup #{attr}" do
            expect(response.body).to have_json_path("lineup/data/attributes/#{attr}")
          end
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing lineup' do
        let!(:lineup) { create :lineup }

        before do
          lineup.fantasy_team.update(user: @current_user)
        end

        context 'for invalid data' do
          before do
            patch :update, params: {
              id: lineup.uuid,
              lineup: { active_chips: [Chipable::BENCH_BOOST, Chipable::BENCH_BOOST] },
              locale: 'en'
            }
          end

          it 'does not update lineup' do
            expect(lineup.reload.active_chips).to eq []
          end

          it 'returns status 422' do
            expect(response).to have_http_status :unprocessable_entity
          end
        end

        context 'for valid data' do
          before do
            patch :update, params: { id: lineup.uuid, lineup: { active_chips: [Chipable::BENCH_BOOST] }, locale: 'en' }
          end

          it 'updates lineup' do
            expect(lineup.reload.active_chips).to eq [Chipable::BENCH_BOOST]
          end

          it 'returns status 200' do
            expect(response).to have_http_status :ok
          end
        end
      end
    end

    def do_request
      patch :update, params: { id: 'unexisting', lineup: { active_chips: [Chipable::BENCH_BOOST] }, locale: 'en' }
    end
  end
end
