# frozen_string_literal: true

describe User do
  it 'factory should be valid' do
    user = build :user

    expect(user).to be_valid
  end

  it { is_expected.to define_enum_for :role }

  describe 'associations' do
    it { is_expected.to have_many(:fantasy_teams).dependent(:destroy) }
    it { is_expected.to have_many(:lineups).through(:fantasy_teams) }
    it { is_expected.to have_one(:users_session).class_name('::Users::Session').dependent(:destroy) }
    it { is_expected.to have_many(:users_achievements).dependent(:destroy) }
    it { is_expected.to have_many(:achievements).through(:users_achievements) }
  end

  describe 'roles?' do
    context 'for regular role' do
      let(:user) { create :user, role: 0 }

      it 'returns true for regular matching' do
        expect(user.regular?).to be_truthy
      end

      it 'returns false for admin matching' do
        expect(user.admin?).to be_falsy
      end
    end

    context 'for admin role' do
      let(:user) { create :user, role: 1 }

      it 'returns false for regular matching' do
        expect(user.regular?).to be_falsy
      end

      it 'returns true for admin matching' do
        expect(user.admin?).to be_truthy
      end
    end
  end

  describe 'award' do
    let!(:user) { create :user }
    let!(:achievement) { create :achievement, award_name: 'fantasy_team_create', points: 5 }

    it 'creates achievement' do
      expect { user.award(achievement: achievement) }.to(
        change(user.users_achievements, :count).by(1)
      )
    end
  end

  describe 'awarded?' do
    let!(:user) { create :user }
    let!(:achievement) { create :achievement, award_name: 'fantasy_team_create', points: 5 }
    let!(:lineup_achievement1) { create :achievement, award_name: 'lineup_points', points: 10, rank: 1 }
    let!(:lineup_achievement2) { create :achievement, award_name: 'lineup_points', points: 25, rank: 2 }

    context 'without achievement, for no rank' do
      it 'returns false' do
        expect(user.awarded?(achievement: achievement)).to be_falsy
      end
    end

    context 'with achievement, for no rank' do
      before { user.award(achievement: achievement) }

      it 'returns true' do
        expect(user.awarded?(achievement: achievement)).to be_truthy
      end
    end

    context 'with achievement, with lower rank' do
      before { user.award(achievement: lineup_achievement1) }

      it 'returns false' do
        expect(user.awarded?(achievement: lineup_achievement2)).to be_falsy
      end
    end

    context 'with achievement, with rank' do
      before { user.award(achievement: lineup_achievement1) }

      it 'returns true' do
        expect(user.awarded?(achievement: lineup_achievement1)).to be_truthy
      end
    end
  end
end
