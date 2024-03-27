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
    it { is_expected.to have_many(:users_sessions).class_name('::Users::Session').dependent(:destroy) }
    it { is_expected.to have_many(:kudos_users_achievements).dependent(:destroy) }
    it { is_expected.to have_many(:kudos_achievements).through(:kudos_users_achievements) }
    it { is_expected.to have_many(:feedbacks).dependent(:destroy) }
    it { is_expected.to have_many(:identities).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
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
end
