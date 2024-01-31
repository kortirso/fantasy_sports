# frozen_string_literal: true

describe AchievementGroupsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      before do
        groups = create_list :kudos_achievement_group, 2
        create :kudos_achievement_group, parent: groups.first
      end

      it 'returns status 200' do
        do_request

        expect(response).to have_http_status :ok
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end
end
