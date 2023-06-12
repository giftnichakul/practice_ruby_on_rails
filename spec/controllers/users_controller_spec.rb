require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe 'GET /users/new' do
    subject { get :new }

    it 'render the sign in page' do
      expect(subject.status).to eq(200)
    end
  end
end
