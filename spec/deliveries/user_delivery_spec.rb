# frozen_string_literal: true

describe UserDelivery, type: :delivery do
  let!(:user) { create :user }
  let!(:week) { create :week }
  let!(:fantasy_team) { create :fantasy_team, user: user }

  before { create :identity, user: user }

  describe '#deadline_report' do
    it 'does not deliver' do
      expect {
        described_class.with(user: user, fantasy_team: fantasy_team, week: week).deadline_report.deliver_later
      }.not_to deliver_via(:mailer, :telegram)
    end

    context 'with enabled notification' do
      before do
        create :notification,
               target: Notification::TELEGRAM,
               notification_type: Notification::DEADLINE_DATA,
               notifyable: user
      end

      it 'delivers to 2 webhooks' do
        expect {
          described_class.with(user: user, fantasy_team: fantasy_team, week: week).deadline_report.deliver_later
        }.to deliver_via(:telegram)
      end
    end
  end
end
