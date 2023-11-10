# frozen_string_literal: true

describe Teams::Players::CorrectPriceService, type: :service do
  subject(:service_call) { described_class.call(week: week) }

  let!(:week) { create :week }
  let!(:teams_player1) { create :teams_player, price_cents: 500 }
  let!(:teams_player2) { create :teams_player, price_cents: 500 }
  let!(:teams_player3) { create :teams_player, price_cents: 500 }
  let!(:teams_player4) { create :teams_player, price_cents: 500 }
  let!(:teams_player5) { create :teams_player, price_cents: 500 }
  let!(:teams_player6) { create :teams_player, price_cents: 500 }
  let!(:teams_player7) { create :teams_player, price_cents: 500 }

  before do
    lineups = create_list :lineup, 20, week: week
    create_list :transfer, 2, lineup: lineups[0], teams_player: teams_player1
    create_list :transfer, 6, lineup: lineups[1], teams_player: teams_player2
    create_list :transfer, 12, lineup: lineups[2], teams_player: teams_player3
    create_list :transfer, 2, lineup: lineups[3], teams_player: teams_player4, direction: Transfer::OUT
    create_list :transfer, 6, lineup: lineups[4], teams_player: teams_player5, direction: Transfer::OUT
    create_list :transfer, 12, lineup: lineups[5], teams_player: teams_player6, direction: Transfer::OUT
    create :transfer, lineup: lineups[6], teams_player: teams_player7
  end

  it 'updates teams players prices', :aggregate_failures do
    service_call

    expect(teams_player1.reload.price_cents).to eq 500 + Teams::Players::CorrectPriceService::PRICE_SMALL_CHANGE
    expect(teams_player2.reload.price_cents).to eq 500 + Teams::Players::CorrectPriceService::PRICE_MEDIUM_CHANGE
    expect(teams_player3.reload.price_cents).to eq 500 + Teams::Players::CorrectPriceService::PRICE_BIG_CHANGE
    expect(teams_player4.reload.price_cents).to eq 500 - Teams::Players::CorrectPriceService::PRICE_SMALL_CHANGE
    expect(teams_player5.reload.price_cents).to eq 500 - Teams::Players::CorrectPriceService::PRICE_MEDIUM_CHANGE
    expect(teams_player6.reload.price_cents).to eq 500 - Teams::Players::CorrectPriceService::PRICE_BIG_CHANGE
    expect(teams_player7.reload.price_cents).to eq 500
  end

  it 'succeed' do
    service = service_call

    expect(service.success?).to be_truthy
  end
end
