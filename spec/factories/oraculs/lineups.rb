# frozen_string_literal: true

FactoryBot.define do
  factory :oraculs_lineup, class: 'Oraculs::Lineup' do
    oracul
    periodable factory: %i[week]
  end
end
