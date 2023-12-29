# frozen_string_literal: true

describe FantasyTeams::CreateJob, type: :service do
  subject(:job_call) { described_class.perform_now(id: id) }

  let!(:fantasy_team) { create :fantasy_team }

  before do
    allow(Achievement).to receive(:award)
  end

  context 'with unexisting fantasy team' do
    let(:id) { 'unexisting' }

    it 'does not award user' do
      job_call

      expect(Achievement).not_to have_received(:award)
    end
  end

  context 'with existing fantasy team' do
    let(:id) { fantasy_team.id }

    it 'awards user' do
      job_call

      expect(Achievement).to have_received(:award).with(:fantasy_team_create, fantasy_team)
    end
  end
end
