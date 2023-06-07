require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  describe 'POST /create' do
    subject { post :create, params: }

    let(:book) { create(:book) }
    let(:params) { { book_id: book.id, review: { comment: 'test review controller', star: 4 } } }

    it 'creates review success' do
      expect(subject.status).to eq(302)
      expect(Review.count).to eq(1)

      # test value of each attributes
      created_review = assigns(:review)
      expect(Review.find(created_review.id).comment).to eq('test review controller')
      expect(Review.find(created_review.id).star).to eq(4)
      expect(Review.find(created_review.id).book).to eq(book)

      # redirect to show page
      expect(subject).to redirect_to(book_path(created_review.book))
    end

    context 'validation' do
      let(:params) { { book_id: book.id, review: { comment: '' } } }

      it 'requires comment' do
        # subject
        expect(subject.status).to eq(302)
        expect(assigns(:review)).not_to be_valid
        expect(Review.count).to eq(0)
      end

      let(:params) { { book_id: book.id, review: { star: 6 } } }

      it 'star must be in range 0 to 5' do
        # subject
        expect(subject.status).to eq(302)
        expect(assigns(:review)).not_to be_valid
        expect(Review.count).to eq(0)
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
    let(:params) { { id: review.id, book_id: review.book, review: { comment: 'test update', star: 4.5 } } }

    it 'updates the review successful' do
      expect(subject.status).to eq(302)

      # test value of each attributes
      updated_review = assigns(:review)
      expect(Review.find(updated_review.id).comment).to eq('test update')
      expect(Review.find(updated_review.id).star).to eq(4.5)
      expect(Review.find(updated_review.id).book).to eq(review.book)

      # redirect to show page
      expect(subject).to redirect_to(book_path(updated_review.book_id))
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

  describe 'private method' do
    let!(:review) { create(:review) }

    describe '#set_book' do
      it 'return a book from review' do
        controller.params[:book_id] = review.book.id
        send_book = controller.send(:set_book)
        expect(send_book).to eq(review.book)
      end
    end
  end
end
