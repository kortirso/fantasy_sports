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
    it { is_expected.to have_many(:achievements).dependent(:destroy) }
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

    it 'creates achievement' do
      expect { user.award(achievement: Achievements::FantasyTeams::Create, points: 5) }.to(
        change(user.achievements, :count).by(1)
      )
    end
  end

  describe 'awarded?' do
    let!(:user) { create :user }

    context 'without achievement, for no rank' do
      it 'returns false' do
        expect(user.awarded?(achievement: Achievements::FantasyTeams::Create)).to be_falsy
      end
    end

    context 'without achievement, with rank' do
      it 'returns false' do
        expect(user.awarded?(achievement: Achievements::Lineups::Points, rank: 1)).to be_falsy
      end
    end

    context 'with achievement, for no rank' do
      before { user.award(achievement: Achievements::FantasyTeams::Create, points: 5) }

      it 'returns true' do
        expect(user.awarded?(achievement: Achievements::FantasyTeams::Create)).to be_truthy
      end
    end

    context 'with achievement, with lower rank' do
      before { user.award(achievement: Achievements::Lineups::Points, rank: 1, points: 10) }

      it 'returns false' do
        expect(user.awarded?(achievement: Achievements::Lineups::Points, rank: 2)).to be_falsy
      end
    end

    context 'with achievement, with rank' do
      before { user.award(achievement: Achievements::Lineups::Points, rank: 1, points: 10) }

      it 'returns true' do
        expect(user.awarded?(achievement: Achievements::Lineups::Points, rank: 1)).to be_truthy
      end
    end
  end
end
