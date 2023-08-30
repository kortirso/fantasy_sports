# frozen_string_literal: true

describe FantasyTeams::Points::UpdateService, type: :service do
  subject(:service_call) {
    described_class.call(fantasy_team_ids: fantasy_team_ids)
  }

  let!(:fantasy_team) { create :fantasy_team }
  let(:fantasy_team_ids) { [fantasy_team.id] }

  before do
    create :lineup, fantasy_team: fantasy_team, points: 4
    create :lineup, fantasy_team: fantasy_team, points: 2
    create :lineup, fantasy_team: fantasy_team, points: 1
  end

  it 'updates fantasy_team points' do
    service_call

    expect(fantasy_team.reload.points).to eq 7
  end

  it 'and it succeed' do
    service = service_call

    expect(service.success?).to be_truthy
  end
end
