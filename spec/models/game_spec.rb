# frozen_string_literal: true

describe Game, type: :model do
  it 'factory should be valid' do
    game = build :game

    expect(game).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:week) }
    it { is_expected.to belong_to(:home_team).class_name('Team').with_foreign_key(:home_team_id) }
    it { is_expected.to belong_to(:visitor_team).class_name('Team').with_foreign_key(:visitor_team_id) }
  end
end
