# frozen_string_literal: true

describe HttpService::Client, type: :client do
  let(:headers) { { 'Content-Type' => 'application/json' } }

  context 'for new connection' do
    it 'creates faraday connection' do
      client_service = described_class.new(url: 'https://www.balldontlie.io')

      expect(client_service.connection.is_a?(Faraday::Connection)).to be_truthy
    end
  end

  context 'for get request' do
    subject(:client_request) {
      described_class.new(url: 'https://www.balldontlie.io', connection: connection)
    }

    before do
      stubs.get('/api/v1/stats') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request.get(path: '/api/v1/stats', params: { game_ids: [1] })).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) {
        {
          'data' => [
            {
              'player' => {
                'first_name' => 'LeBron',
                'last_name' => 'James'
              },
              'pts' => 50
            }
          ]
        }
      }

      it 'returns players data' do
        expect(client_request.get(path: '/api/v1/stats', params: { game_ids: [1] })).to eq body
      end
    end
  end

  context 'for post request' do
    subject(:client_request) {
      described_class.new(url: 'https://api-football.instatscout.com', connection: connection)
    }

    before do
      stubs.post('/widgets') { [status, headers, body.to_json] }
    end

    context 'for invalid response' do
      let(:status) { 403 }
      let(:errors) { [{ 'detail' => 'Forbidden' }] }
      let(:body) { { 'errors' => errors } }

      it 'returns nil' do
        expect(client_request.post(path: '/widgets', params: { page: 1 })).to be_nil
      end
    end

    context 'for valid response' do
      let(:status) { 200 }
      let(:body) {
        {
          'data' => [
            {
              'scout_match_players_stat' => {
                'team1_stat' => {},
                'team2_stat' => {}
              }
            }
          ]
        }
      }

      it 'returns user_id' do
        expect(client_request.post(path: '/widgets')).to eq body
      end
    end
  end
end
