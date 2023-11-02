# frozen_string_literal: true

describe SchedulerJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:season) { create :season, active: true, start_at: DateTime.new(2023, 1, 1, 0, 10, 0) }
  let!(:week1) {
    create :week, status: Week::INACTIVE, season: season, position: 1, deadline_at: DateTime.new(2023, 1, 7, 0, 10, 0)
  }
  let!(:week2) {
    create :week, status: Week::INACTIVE, season: season, position: 2, deadline_at: DateTime.new(2023, 1, 14, 0, 10, 0)
  }
  let!(:game) { create :game, week: week1, start_at: DateTime.new(2023, 1, 7, 21, 0, 0) }

  before do
    allow(Weeks::ChangeService).to receive(:call)
    allow(Games::ImportJob).to receive(:perform_later)
    allow(Achievements::RefreshAfterWeekChangeJob).to receive(:perform_later)
    allow(Teams::Players::CorrectPricesJob).to receive(:perform_later)
    allow(Achievements::RefreshAfterGameJob).to receive(:perform_later)
  end

  context 'when no season to start' do
    it 'does nothing', :aggregate_failures do
      job_call

      expect(week1.reload.status).to eq Week::INACTIVE
      expect(week2.reload.status).to eq Week::INACTIVE
      expect(Weeks::ChangeService).not_to have_received(:call)
      expect(Games::ImportJob).not_to have_received(:perform_later)
      expect(Achievements::RefreshAfterGameJob).not_to have_received(:perform_later)
    end
  end

  context 'when there is season to start' do
    before { Timecop.freeze(2023, 1, 1) }
    after { Timecop.return }

    it 'updates week status', :aggregate_failures do
      job_call

      expect(week1.reload.status).to eq Week::COMING
      expect(week2.reload.status).to eq Week::INACTIVE
      expect(Weeks::ChangeService).not_to have_received(:call)
      expect(Games::ImportJob).not_to have_received(:perform_later)
      expect(Achievements::RefreshAfterGameJob).not_to have_received(:perform_later)
    end
  end

  context 'when coming week close to deadline' do
    before do
      week1.update(status: Week::COMING)
      Timecop.freeze(2023, 1, 7)
    end

    after { Timecop.return }

    it 'calls week change service', :aggregate_failures do
      job_call

      expect(Weeks::ChangeService).to have_received(:call).with(week_id: week1.id)
      expect(Achievements::RefreshAfterWeekChangeJob).to have_received(:perform_later).with(week_id: week1.id)
      expect(Teams::Players::CorrectPricesJob).to have_received(:perform_later).with(week_id: week1.id)
      expect(Games::ImportJob).not_to have_received(:perform_later)
      expect(Achievements::RefreshAfterGameJob).not_to have_received(:perform_later)
    end
  end

  context 'when game is started' do
    before do
      week1.update(status: Week::ACTIVE)
      Timecop.freeze(2023, 1, 8)
    end

    after { Timecop.return }

    it 'calls game import job', :aggregate_failures do
      job_call

      expect(Weeks::ChangeService).not_to have_received(:call)
      expect(Games::ImportJob).to have_received(:perform_later).with(game_ids: [game.id])
      expect(Games::ImportJob).to have_received(:perform_later).with(game_ids: [game.id])
      expect(Achievements::RefreshAfterGameJob).to have_received(:perform_later)
    end

    context 'when game has points' do
      before { game.update!(points: [1, 2]) }

      it 'does not call game import job', :aggregate_failures do
        job_call

        expect(Weeks::ChangeService).not_to have_received(:call)
        expect(Games::ImportJob).not_to have_received(:perform_later)
        expect(Achievements::RefreshAfterGameJob).not_to have_received(:perform_later)
      end
    end

    context 'when game is not finished yet' do
      before { game.update!(start_at: DateTime.new(2023, 1, 7, 22, 0, 0)) }

      it 'does not call game import job', :aggregate_failures do
        job_call

        expect(Weeks::ChangeService).not_to have_received(:call)
        expect(Games::ImportJob).not_to have_received(:perform_later)
        expect(Achievements::RefreshAfterGameJob).not_to have_received(:perform_later)
      end
    end
  end
end
