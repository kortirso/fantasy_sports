# frozen_string_literal: true

describe Weeks::StartService, type: :service do
  subject(:service_call) {
    described_class.call(week: week)
  }

  context 'for nil week' do
    let(:week) { nil }

    before do
      allow(week).to receive(:update)
    end

    it 'does not update week' do
      service_call

      expect(week).not_to have_received(:update)
    end

    it 'and it succeed' do
      service = service_call

      expect(service.success?).to be_truthy
    end
  end

  context 'for existing week' do
    let!(:fantasy_team) { create :fantasy_team, transfers_limited: false }

    before do
      create :lineup, fantasy_team: fantasy_team, week: week
    end

    context 'for not coming week' do
      let!(:week) { create :week, status: Week::INACTIVE }

      it 'does not update week' do
        service_call

        expect(week.reload.status).not_to eq Week::ACTIVE
      end

      it 'does not update fantasy team' do
        service_call

        expect(fantasy_team.reload.transfers_limited).to be false
      end

      it 'and it succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end

    context 'for coming week' do
      let!(:week) { create :week, status: Week::COMING }

      it 'updates week' do
        service_call

        expect(week.reload.status).to eq Week::ACTIVE
      end

      it 'does updates fantasy team' do
        service_call

        expect(fantasy_team.reload.transfers_limited).to be true
      end

      it 'and it succeed' do
        service = service_call

        expect(service.success?).to be_truthy
      end
    end
  end
end
