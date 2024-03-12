# frozen_string_literal: true

RSpec.describe UserSerializer do
  subject(:serializer) { described_class.new(user, params: serializer_fields).serializable_hash }

  let!(:user) { create :user }

  context 'for serializer_fields without values' do
    let(:serializer_fields) { {} }

    it 'does not return any values', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(serializer.dig(:data, :id)).not_to eq user.id
      expect(attributes[:banned]).to be_nil
      expect(attributes[:confirmed]).to be_nil
      expect(attributes[:access_token]).to be_nil
    end
  end

  context 'when include_fields is present' do
    let(:serializer_fields) { { include_fields: ['banned'] } }

    it 'returns all included values', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(serializer.dig(:data, :id)).not_to eq user.id
      expect(attributes[:banned]).to be_falsy
      expect(attributes[:confirmed]).to be_nil
      expect(attributes[:access_token]).to be_nil
    end
  end

  context 'when exclude_fields is present' do
    let(:serializer_fields) { { exclude_fields: ['banned'] } }

    it 'returns all values except excluded', :aggregate_failures do
      attributes = serializer.dig(:data, :attributes)

      expect(serializer.dig(:data, :id)).not_to eq user.id
      expect(attributes[:banned]).to be_nil
      expect(attributes[:confirmed]).to be_truthy
      expect(attributes[:access_token]).not_to be_nil
    end
  end
end
