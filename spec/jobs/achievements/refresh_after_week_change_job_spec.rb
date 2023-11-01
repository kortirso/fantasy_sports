# frozen_string_literal: true

describe Achievements::RefreshAfterWeekChangeJob, type: :service do
  subject(:job_call) { described_class.perform_now(week_id: week_id) }

  let!(:week) { create :week, position: 1, status: 'coming' }

  before do
    allow(Achievements::Lineups::DiversityJob).to receive(:perform_later)
    allow(Achievements::Lineups::TopPointsJob).to receive(:perform_later)
  end

  context 'for unexisting week' do
    let(:week_id) { 'unexisting' }

    it 'does not publish events', :aggregate_failures do
      job_call

      expect(Achievements::Lineups::DiversityJob).not_to have_received(:perform_later)
      expect(Achievements::Lineups::TopPointsJob).not_to have_received(:perform_later)
    end
  end

  context 'for existing week' do
    let(:week_id) { week.id }

    context 'for existing week, without previous' do
      it 'publishes 1 event', :aggregate_failures do
        job_call

        expect(Achievements::Lineups::DiversityJob).to have_received(:perform_later).with(week_id: week.id)
        expect(Achievements::Lineups::TopPointsJob).not_to have_received(:perform_later)
      end
    end

    context 'for existing week, with previous' do
      before { create :week, position: 0, season: week.season }

      it 'publishes 2 events', :aggregate_failures do
        job_call

        expect(Achievements::Lineups::DiversityJob).to have_received(:perform_later).with(week_id: week.id)
        expect(Achievements::Lineups::TopPointsJob).to have_received(:perform_later).with(week_id: week.previous.id)
      end
    end
  end
end
