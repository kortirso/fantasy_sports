# frozen_string_literal: true

describe IdentitiesController do
  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      let!(:identity) { create :identity }
      let(:request) { delete :destroy, params: { id: identity.id } }

      before do
        create :notification, target: identity.provider, notifyable: @current_user
      end

      context 'for not user identity' do
        it 'does not destroy identity', :aggregate_failures do
          expect { request }.not_to change(Identity, :count)
          expect(response).to redirect_to profile_path
        end
      end

      context 'for user identity' do
        before { identity.update!(user: @current_user) }

        it 'destroys identity', :aggregate_failures do
          expect { request }.to(
            change(Identity, :count).by(-1)
              .and(change(Notification, :count).by(-1))
          )
          expect(response).to redirect_to profile_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
