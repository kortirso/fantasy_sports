# frozen_string_literal: true

describe Achievements::FantasyTeams::Create, type: :service do
  subject(:achievement_call) { described_class.award_for(fantasy_team: fantasy_team) }

  let(:user) { create :user }
  let!(:fantasy_team) { create :fantasy_team, user: user }

  context 'if user does not have achievement' do
    it 'creates achievement' do
      expect { achievement_call }.to change(user.achievements, :count).by(1)
    end
  end

  context 'if user has achievement' do
    before { user.award(achievement: described_class, points: 5) }

    it 'does not create achievement' do
      expect { achievement_call }.not_to change(user.achievements, :count)
    end
  end
end
