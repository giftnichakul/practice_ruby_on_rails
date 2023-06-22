require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'valid factory' do
    subject(:factory) { build(:user) }

    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to have_many(:books) }
    it { is_expected.to have_many(:reviews) }
  end
end
