# frozen_string_literal: true

RSpec.describe SeasonSerializer do
  subject(:serializer) { described_class.new(season, params: serializer_fields).serializable_hash }

  let!(:season) { create :season }

  context 'when include_fields is present' do
    let(:serializer_fields) { { include_fields: ['name'] } }

    it 'returns all included values', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(attributes[:id]).to be_nil
      expect(attributes[:name]).not_to be_nil
      expect(attributes[:league_id]).to be_nil
    end
  end
end
