# frozen_string_literal: true

describe BannedEmail do
  it 'factory should be valid' do
    banned_email = build :banned_email

    expect(banned_email).to be_valid
  end
end
