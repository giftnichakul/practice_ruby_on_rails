require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'valid factory' do
    subject(:factory) { build(:review) }

    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:book) }
  end
end
