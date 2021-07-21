require 'rails_helper'

module Keycloak
  RSpec.describe SetupStudentAccount do
    specify 'should update the external id attribute for a user' do
      user = create(:user, email: 'random@example.com')
      fake_client = FakeClient.new(id: ->(email) { email == 'random@example.com' ? '123456789' : SecureRandom.uuid})
      SetupStudentAccount.new(fake_client).call(actor_id: user.id)

      user.reload

      expect(user.external_id).to eq('123456789')
    end
  end
end
