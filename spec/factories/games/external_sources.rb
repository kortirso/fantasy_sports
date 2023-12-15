# frozen_string_literal: true

FactoryBot.define do
  factory :games_external_source, class: 'Games::ExternalSource' do
    source { Sourceable::SPORTS }
    external_id { 'external_id' }
    game
  end
end
