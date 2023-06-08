require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  describe 'POST /create' do
    subject { post :create, params: }

    let(:book) { create(:book) }
    let(:params) do
      {
        book_id: book.id,
        review: { comment: 'test review controller', star: 4 }
      }
    end

    it 'creates review success' do
      expect(subject.status).to eq(302)
      expect(Review.count).to eq(1)
    end

    it 'saves value to database' do
      subject
      created_review = Review.find(assigns(:review).id)
      expect(created_review.comment).to eq('test review controller')
      expect(created_review.star).to eq(4)
      expect(created_review.book).to eq(book)
    end

    it 'redirect to show book path' do
      subject
      expect(subject).to redirect_to(book_path(assigns(:review).book))
    end

    context 'validation for comment' do
      let(:book) { create(:book) }
      let(:params) { { book_id: book.id, review: { comment: '', star: 4} } }

      it 'requires comment' do
        expect(subject.status).to eq(302)
        expect(assigns(:review)).not_to be_valid
        expect(Review.count).to eq(0)
        expect(subject).to redirect_to(book_path(id: assigns(:review).book_id, error: ["Comment can't be blank"]))
      end
    end

    context 'validation for star' do
      let(:book) { create(:book) }
      let(:params) { { book_id: book.id, review: { comment: 'star is not in range', star: 6 } } }

      it 'star must be in range 0 to 5' do
        expect(subject.status).to eq(302)
        expect(assigns(:review)).not_to be_valid
        expect(Review.count).to eq(0)
        expect(subject).to redirect_to(book_path(id: assigns(:review).book_id, error: ["Star must be in 0..5"]))
      end
    end
  end

  describe 'GET /edit' do
    subject { get :edit, params: }

    let(:review) { create(:review) }
    let(:params) { { book_id: review.book, id: review.id } }

    it 'renders to edit review form' do
      expect(subject.status).to eq(200)
      expect(subject).to render_template(:edit)
    end
  end

  describe 'PUT /update' do
    subject { put :update, params: }

    let(:review) { create(:review) }
    let(:params) do
      {
        id: review.id,
        book_id: review.book,
        review: { comment: 'test update', star: 4.5 }
      }
    end

    it 'updates the review successful' do
      expect(subject.status).to eq(302)
    end

    it 'updates value in database' do
      subject
      updated_review = Review.find(assigns(:review).id)
      expect(updated_review.comment).to eq('test update')
      expect(updated_review.star).to eq(4.5)
      expect(updated_review.book).to eq(review.book)
    end

    it 'redirect to show page' do
      expect(subject).to redirect_to(book_path(assigns(:review).book_id))
    end

    let(:invalid_comment) { { comment: '' } }

    it 'renders the edit page for invalid comment' do
      put :update, params: { id: review.id, book_id: review.book, review: invalid_comment }

      expect(response).to have_http_status(200)
      expect(response).to render_template(:edit)
      expect(review.comment).not_to eq('')
    end

    let(:invalid_star) { { star: -1 } }

    it 'renders the edit page for invalid star' do
      put :update, params: { id: review.id, book_id: review.book, review: invalid_star }

      expect(response).to have_http_status(200)
      expect(response).to render_template(:edit)
      expect(review.star).not_to eq(-1)
    end
  end

  describe 'DELETE /destroy' do
    let!(:review) { create(:review) }
    let!(:book_id) { review.book }

    it 'deletes the review' do
      expect { delete :destroy, params: { id: review.id, book_id: review.book } }.to change(Review, :count).by(-1)
      expect(response).to have_http_status(302)

      expect(response).to redirect_to(book_path(book_id))
    end
  end
end
