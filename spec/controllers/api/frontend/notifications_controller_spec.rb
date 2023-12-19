# frozen_string_literal: true

describe Api::Frontend::NotificationsController do
  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:request) {
          post :create, params: { notification: { target: 'telegram', notification_type: '' } }
        }

        it 'does not create notification', :aggregate_failures do
          expect { request }.not_to change(Notification, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq 'Notification type must be filled'
        end
      end

      context 'for existing notification' do
        let(:request) {
          post :create, params: { notification: { target: 'telegram', notification_type: 'deadline_data' } }
        }

        before do
          create :notification, notifyable: @current_user, target: 'telegram', notification_type: 'deadline_data'
        end

        it 'does not create notification', :aggregate_failures do
          expect { request }.not_to change(Notification, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq 'Notification already exists'
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: { notification: { target: 'telegram', notification_type: 'deadline_data' } }
        }

        it 'creates notification', :aggregate_failures do
          expect { request }.to change(@current_user.notifications.telegram, :count).by(1)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).to be_nil
        end
      end
    end

    def do_request
      post :create, params: { notification: { target: 'telegram', notification_type: 'deadline_data' } }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      let!(:notification) { create :notification, target: Notification::TELEGRAM, notification_type: 'deadline_data' }
      let(:request) do
        delete :destroy, params: { notification: { target: 'telegram', notification_type: 'deadline_data' } }
      end

      context 'for not user notification' do
        it 'does not destroy notification', :aggregate_failures do
          expect { request }.not_to change(Notification, :count)
          expect(response).to have_http_status :not_found
        end
      end

      context 'for user notification' do
        before { notification.update!(notifyable: @current_user) }

        it 'destroys notification', :aggregate_failures do
          expect { request }.to change(Notification, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { notification: { target: 'telegram', notification_type: 'deadline_data' } }
    end
  end
end
