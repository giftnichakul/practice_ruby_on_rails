require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  describe 'GET /index' do
    subject { get :index }

    it 'returns all books' do
      expect(subject.status).to eq(200)
      expect(assigns(:books)).to eq(Book.all)
    end
  end

  describe 'GET /show' do
    subject { get :show, params: }

    let(:book) { create(:book) }
    let(:params) { { id: book.id } }

    context 'when book exist' do
      it 'returns book' do
        expect(subject.status).to eq(200)
        expect(subject).to render_template(:show)
        expect(assigns(:book)).to eq(Book.find(book.id))
      end
    end

    context 'when book not exist' do
      let(:params) { { id: -1 } }

      it 'raise error not found' do
        # expect(subject.status).to eq(404)
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET /new' do
    subject { get :new }

    it 'renders to new book form' do
      expect(subject.status).to eq(200)
      expect(subject).to render_template(:new)
    end
  end

  describe 'POST /create' do
    subject { post :create, params: }

    let(:params) { { book: { name: 'Controller book', description: 'Book from controller', release: '2023-01-01' } } }

    it 'creates a book success' do
      expect(subject.status).to eq(302)
      expect(Book.count).to eq(1)

      # test value of each attributes
      created_book = assigns(:book)
      expect(Book.find(created_book.id).name).to eq('Controller book')
      expect(Book.find(created_book.id).description).to eq('Book from controller')
      expect(Book.find(created_book.id).release).to eq(Date.new(2023, 1, 1))

      # redirect to show page
      expect(subject).to redirect_to(book_path(created_book.id))
    end

    context 'validation' do
      let(:params) { { book: { name: '' } } }

      it 'requires name' do
        expect(subject.status).to eq(200)
        expect(assigns(:book)).not_to be_valid
        expect(Book.count).to eq(0)

        # render new page
        expect(subject).to render_template(:new)
      end
    end
  end

  describe 'GET /edit' do
    subject { get :edit, params: }

    let(:book) { create(:book) }
    let(:params) { { id: book.id } }

    it 'renders to edit book form' do
      expect(subject.status).to eq(200)
      expect(subject).to render_template(:edit)
    end
  end

  describe 'PUT /update' do
    subject { put :update, params: }

    let!(:book) { create(:book) }
    let(:invalid_attributes) { { name: '', description: 'invalid name' } }

    it 'renders the edit page for invalid attributes' do
      put :update, params: { id: book.id, book: invalid_attributes }

      # expect(subject.status).to eq(200)
      expect(response).to have_http_status(200)
      expect(response).to render_template(:edit)
      expect(book.description).not_to eq('invalid name')
    end

    let(:params) { { id: book.id, book: { name: 'ubook', description: 'updates book', release: '2022-01-01' } } }

    it 'updates the book successful' do
      expect(subject.status).to eq(302)

      # test value of each attributes
      updated_book = assigns(:book)
      expect(Book.find(updated_book.id).name).to eq('ubook')
      expect(Book.find(updated_book.id).description).to eq('updates book')
      expect(Book.find(updated_book.id).release).to eq(Date.new(2022, 1, 1))

      # redirect to show page
      expect(subject).to redirect_to(book_path(updated_book.id))
    end
  end

  describe 'DELETE /destroy' do
    let!(:book) { create(:book) }

    it 'deletes the book' do
      expect { delete :destroy, params: { id: book.id } }.to change(Book, :count).by(-1)
      expect(response).to have_http_status(302)

      expect(response).to redirect_to(books_path)
    end
  end

  describe 'private method' do
    let!(:book) { create(:book) }

    describe '#set_book' do
      it 'return a book' do
        controller.params[:id] = book.id
        send_book = controller.send(:set_book)
        expect(send_book).to eq(book)
      end
    end
  end
end
