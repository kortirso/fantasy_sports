# frozen_string_literal: true

RSpec.describe CupSerializer do
  subject(:serializer) { described_class.new(cup, params: serializer_fields).serializable_hash }

  let!(:cup) { create :cup }

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
