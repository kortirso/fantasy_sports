# frozen_string_literal: true

describe AchievementsController do
  describe 'GET#index' do
    let!(:groups) { create_list :kudos_achievement_group, 2 }
    let!(:group) { create :kudos_achievement_group, parent: groups.first }
    let!(:achievement1) { create :kudos_achievement, kudos_achievement_group: groups.first }
    let!(:achievement2) { create :kudos_achievement, kudos_achievement_group: groups.last }
    let!(:achievement3) { create :kudos_achievement, kudos_achievement_group: group }
    let!(:achievement4) { create :kudos_achievement, kudos_achievement_group: groups.first }
    let!(:users_achievement1) { create :kudos_users_achievement, kudos_achievement: achievement1 }
    let!(:users_achievement2) { create :kudos_users_achievement, kudos_achievement: achievement2 }
    let!(:users_achievement3) { create :kudos_users_achievement, kudos_achievement: achievement3 }

    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      before do
        users_achievement1.update(user: @current_user)
        users_achievement2.update(user: @current_user)
        users_achievement3.update(user: @current_user)

        create :kudos_users_achievement, kudos_achievement: achievement4
      end

      context 'for request without group uuid' do
        before { do_request }

        it 'returns all user achievements', :aggregate_failures do
          data = response.parsed_body['achievements']['data']

          expect(data.size).to eq 3
          expect(data.pluck('id').map(&:to_i)).to(
            contain_exactly(users_achievement1.id, users_achievement2.id, users_achievement3.id)
          )
          expect(response).to have_http_status :ok
        end
      end

      context 'for request with group uuid' do
        before { get :index, params: { group_uuid: groups.first.uuid, locale: 'en' } }

        it 'returns user achievements from specific group and sub-groups', :aggregate_failures do
          data = response.parsed_body['achievements']['data']

          expect(data.size).to eq 2
          expect(data.pluck('id').map(&:to_i)).to contain_exactly(users_achievement1.id, users_achievement3.id)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end
end
