require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe 'GET /users/sign_in' do
    subject { get :new }

    it 'render the sign in page' do
      expect(subject.status).to eq(200)
    end
  end

  describe 'POST /users/sign_in' do
    subject { post :create, params: }
    context 'with valid credentials' do
      let(:user) { create(:user) }
      let(:params) { { user: { email: user.email, password: user.password } } }

      it 'signs in the user' do
        expect(subject.status).to eq(303)
        expect(subject).to redirect_to(root_path)
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with invalid credentials' do
      let(:user) { create(:user) }
      let(:params) { { user: { email: user.email, password: user.password + '_' } } }

      it 'render the sign in page' do
        expect(subject.status).to eq(422)
      end
    end
  end

  describe 'DELETE /users/sign_out' do
    subject { delete :destroy }
    let(:user) { create(:user) }

    before { sign_in user }

    it 'signs out the user' do
      expect(subject.status).to eq(303)
      expect(subject).to redirect_to(root_path)
      expect(controller.current_user).to be_nil
    end
  end
end
