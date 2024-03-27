# frozen_string_literal: true

describe LikesController do
  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing likeable_type' do
        let(:request) {
          post :create, params: {
            likeable_id: 'unexisting',
            likeable_type: 'unexisting',
            redirect: 'draft_players'
          }
        }

        it 'does not create like', :aggregate_failures do
          expect { do_request }.not_to change(Like, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing season' do
        it 'does not create like', :aggregate_failures do
          expect { do_request }.not_to change(Like, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing season' do
        let!(:season) { create :season }
        let(:request) {
          post :create, params: { likeable_id: season.id, likeable_type: 'Season', redirect: 'draft_players' }
        }

        context 'if like is already exist' do
          before { create :like, user: @current_user, likeable: season }

          it 'does not create like', :aggregate_failures do
            expect { request }.not_to change(Like, :count)
            expect(response).to redirect_to draft_players_path
          end
        end

        context 'if like does not exist' do
          it 'does not create like', :aggregate_failures do
            expect { request }.to change(@current_user.likes, :count).by(1)
            expect(response).to redirect_to draft_players_path
          end
        end
      end

      context 'for existing cup' do
        let!(:cup) { create :cup }
        let(:request) {
          post :create, params: { likeable_id: cup.id, likeable_type: 'Cup', redirect: 'oracul_places' }
        }

        context 'if like is already exist' do
          before { create :like, user: @current_user, likeable: cup }

          it 'does not create like', :aggregate_failures do
            expect { request }.not_to change(Like, :count)
            expect(response).to redirect_to oracul_places_path
          end
        end

        context 'if like does not exist' do
          it 'does not create like', :aggregate_failures do
            expect { request }.to change(@current_user.likes, :count).by(1)
            expect(response).to redirect_to oracul_places_path
          end
        end
      end
    end

    def do_request
      post :create, params: { likeable_id: 'unexisting', likeable_type: 'Season', redirect: 'draft_players' }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      let!(:like) { create :like }
      let(:request) { delete :destroy, params: { id: like.id, redirect: 'draft_players' } }

      context 'for not user like' do
        it 'does not destroy like', :aggregate_failures do
          expect { request }.not_to change(Like, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for user like' do
        before { like.update!(user: @current_user) }

        it 'destroys like', :aggregate_failures do
          expect { request }.to change(Like, :count).by(-1)
          expect(response).to redirect_to draft_players_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
