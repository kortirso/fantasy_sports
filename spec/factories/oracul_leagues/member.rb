# frozen_string_literal: true

FactoryBot.define do
  factory :oracul_leagues_member, class: 'OraculLeagues::Member' do
    oracul_league
    oracul
  end
end
