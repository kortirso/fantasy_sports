# frozen_string_literal: true

RSpec.describe OraculSerializer do
  subject(:serializer) { described_class.new(oracul, params: serializer_fields).serializable_hash }

  let!(:oracul) { create :oracul }

  context 'when include_fields is present' do
    let(:serializer_fields) { { include_fields: ['name'] } }

    it 'returns all included values', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(attributes[:uuid]).to be_nil
      expect(attributes[:name]).not_to be_nil
      expect(attributes[:oracul_place_id]).to be_nil
    end
  end
end
