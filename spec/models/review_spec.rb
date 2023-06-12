require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'valid factory' do
    subject(:factory) { build(:review) }

    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:comment) }
    it { is_expected.to validate_numericality_of(:star) }
    # it { expect(subject.star).to be_between(0, 5) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:user) }
  end
end
