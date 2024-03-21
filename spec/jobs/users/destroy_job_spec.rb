# frozen_string_literal: true

describe Users::DestroyJob do
  subject(:job_call) { described_class.perform_now(id: id) }

  let!(:user) { create :user }

  context 'for unexisting user' do
    let(:id) { 'unexisting' }

    it 'does not destroy user' do
      expect { job_call }.not_to change(User, :count)
    end
  end

  context 'for existing user' do
    let(:id) { user.id }

    it 'does not destroy user' do
      expect { job_call }.to change(User, :count).by(-1)
    end
  end
end
