# frozen_string_literal: true

RSpec.describe LeagueSerializer do
  subject(:serializer) { described_class.new(league, params: serializer_fields).serializable_hash }

  let!(:league) { create :league }

  context 'for serializer_fields without values' do
    let(:serializer_fields) { {} }

    it 'does not return any values', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(attributes[:id]).to be_nil
      expect(attributes[:name]).to be_nil
      expect(attributes[:sport_kind]).to be_nil
      expect(attributes[:background_url]).to be_nil
    end
  end

  context 'when include_fields is present' do
    let(:serializer_fields) { { include_fields: ['name'] } }

    it 'returns all included values', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(attributes[:id]).to be_nil
      expect(attributes[:name]).not_to be_nil
      expect(attributes[:sport_kind]).to be_nil
      expect(attributes[:background_url]).to be_nil
    end
  end

  context 'when exclude_fields is present' do
    let(:serializer_fields) { { exclude_fields: ['sport_kind'] } }

    it 'returns all values except excluded', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(attributes[:id]).not_to be_nil
      expect(attributes[:name]).not_to be_nil
      expect(attributes[:sport_kind]).to be_nil
      expect(attributes[:background_url]).not_to be_nil
    end
  end
end
