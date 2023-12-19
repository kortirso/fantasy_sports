# frozen_string_literal: true

describe Deliveries::User::DeadlineReportJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:user) { create :user }
  let!(:week) { create :week, status: Week::COMING }
  let!(:fantasy_team) { create :fantasy_team, user: user }
  let(:delivery_service) { double }

  before do
    create :lineup, week: week, fantasy_team: fantasy_team

    allow(UserDelivery).to receive(:with).and_return(delivery_service)
    allow(delivery_service).to receive(:deadline_report).and_return(delivery_service)
    allow(delivery_service).to receive(:deliver_later)
  end

  context 'without notifications' do
    it 'does not calls service' do
      job_call

      expect(UserDelivery).not_to have_received(:with)
    end
  end

  context 'with notification' do
    before { create :notification, notifyable: user, notification_type: Notification::DEADLINE_DATA }

    context 'without close deadlines' do
      it 'does not calls service' do
        job_call

        expect(UserDelivery).not_to have_received(:with)
      end
    end

    context 'with more than 1 day deadline' do
      before { week.update!(deadline_at: 2.days.after) }

      it 'does not calls service' do
        job_call

        expect(UserDelivery).not_to have_received(:with)
      end
    end

    context 'with 1 day deadline' do
      before { week.update!(deadline_at: 1.day.after) }

      it 'calls service' do
        job_call

        expect(UserDelivery).to have_received(:with).with(user: user, fantasy_team: fantasy_team, week: week)
      end
    end

    context 'with 1 hour deadline' do
      before { week.update!(deadline_at: 1.hour.after) }

      it 'calls service' do
        job_call

        expect(UserDelivery).to have_received(:with).with(user: user, fantasy_team: fantasy_team, week: week)
      end
    end
  end
end
