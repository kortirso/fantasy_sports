# frozen_string_literal: true

describe HttpService::Client, type: :client do
  subject(:client_request) { described_class.new(url: 'https://api-football.instatscout.com', connection: connection) }

  let(:headers) { { 'Content-Type' => 'application/json' } }

  before do
    stubs.post('/widgets') { [status, headers, body.to_json] }
  end

  context 'for invalid response' do
    let(:status) { 403 }
    let(:errors) { [{ 'detail' => 'Forbidden' }] }
    let(:body) { { 'errors' => errors } }

    it 'returns nil' do
      expect(client_request.post(path: '/widgets')).to be_nil
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
