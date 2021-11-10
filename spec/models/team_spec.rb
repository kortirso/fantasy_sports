# frozen_string_literal: true

describe Team, type: :model do
  it 'factory should be valid' do
    team = build :team

    expect(team).to be_valid
  end
end
