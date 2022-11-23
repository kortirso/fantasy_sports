# frozen_string_literal: true

describe Achievements::Lineups::Points, type: :service do
  subject(:achievement_call) { described_class.award_for(lineup: lineup) }

  let(:user) { create :user }
  let(:fantasy_team) { create :fantasy_team, user: user }
  let!(:lineup) { create :lineup, fantasy_team: fantasy_team, points: 55 }

  context 'if user does not have achievement' do
    it 'creates achievement' do
      expect { achievement_call }.to change(user.achievements, :count).by(1)
    end

    it 'new achievement has points for 2 rank', :aggregate_failures do
      achievement_call

      achievement = user.achievements.last

      expect(achievement.rank).to eq 2
      expect(achievement.points).to eq 25
    end
  end

  context 'if user has lower rank achievement' do
    let!(:achievement) { create :achievement, type: described_class.to_s, user: user, rank: 1, points: 10 }

    it 'does not create new achievement' do
      expect { achievement_call }.not_to change(user.achievements, :count)
    end

    it 'updates achievement', :aggregate_failures do
      achievement_call

      expect(achievement.reload.rank).to eq 2
      expect(achievement.points).to eq 25
    end
  end

  context 'if user has the same or higher rank achievement' do
    let!(:achievement) { create :achievement, type: described_class.to_s, user: user, rank: 3, points: 50 }

    it 'does not create new achievement' do
      expect { achievement_call }.not_to change(user.achievements, :count)
    end

    it 'does not update achievement', :aggregate_failures do
      achievement_call

      expect(achievement.reload.rank).to eq 3
      expect(achievement.points).to eq 50
    end
  end
end
