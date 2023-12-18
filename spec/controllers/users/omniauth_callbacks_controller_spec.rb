# frozen_string_literal: true

describe Users::OmniauthCallbacksController do
  describe 'POST#create' do
    let(:code) { nil }
    let(:request) { post :create, params: { provider: provider, code: code } }

    context 'for unexisting provider' do
      let(:provider) { 'unknown' }

      it 'redirects to login path', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to redirect_to users_login_path
      end
    end

    context 'for telegram' do
      let(:request) { post :create, params: { provider: provider, id: id } }
      let(:id) { nil }
      let(:provider) { Identity::TELEGRAM }

      context 'for blank id' do
        it 'redirects to login path', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_login_path
        end
      end

      context 'for present id' do
        let(:id) { 'id' }

        before do
          allow(FantasySports::Container.resolve('services.auth.providers.telegram')).to(
            receive(:call).and_return(telegram_auth_result)
          )
        end

        context 'for invalid id' do
          let(:telegram_auth_result) { { result: nil } }

          it 'redirects to login path', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to users_login_path
          end
        end

        context 'for valid id' do
          let(:telegram_auth_result) { { result: auth_payload } }

          context 'for not logged user' do
            context 'for valid payload' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'telegram',
                  login: 'octocat'
                }
              end

              it 'redirects to root path', :aggregate_failures do
                expect { request }.not_to change(User, :count)
                expect(response).to redirect_to root_path
              end
            end
          end

          context 'for logged user' do
            sign_in_user

            context 'for valid payload' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'telegram',
                  login: 'octocat'
                }
              end

              it 'redirects to profile path', :aggregate_failures do
                expect { request }.to change(Identity, :count).by(1)
                expect(response).to redirect_to profile_path
              end
            end
          end
        end
      end
    end
  end
end
