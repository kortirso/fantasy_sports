# frozen_string_literal: true

describe Games::ExternalSource do
  it 'factory should be valid' do
    games_external_source = build :games_external_source

    expect(games_external_source).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:game) }
  end
end
