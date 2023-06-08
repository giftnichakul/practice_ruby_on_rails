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

    let(:params) do
      {
        book: {
          name: 'Controller book',
          description: 'Book from controller',
          release: '2023-01-01'
        }
      }
    end

    it 'creates a book success' do
      expect(subject.status).to eq(302)
      expect(Book.count).to eq(1)
    end

    it 'saves value to database' do
      subject
      created_book = Book.find(assigns(:book).id)
      expect(created_book.name).to eq('Controller book')
      expect(created_book.description).to eq('Book from controller')
      expect(created_book.release).to eq(Date.new(2023, 1, 1))
    end

    it 'redirects to show book page' do
      subject
      expect(subject).to redirect_to(book_path(assigns(:book).id))
    end

    context 'validation' do
      let(:params) { { book: { name: '' } } }

      it 'requires name' do
        expect(subject.status).to eq(302)
        expect(assigns(:book)).not_to be_valid
        expect(Book.count).to eq(0)
      end

      it 'render new book page again' do
        subject
        expect(subject).to redirect_to(new_book_path(error: ["Name can't be blank"]))
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

      expect(response).to have_http_status(200)
      expect(response).to render_template(:edit)
      expect(book.description).not_to eq('invalid name')
    end

    let(:params) do
      {
        id: book.id,
        book: {
          name: 'ubook',
          description: 'updates book',
          release: '2022-01-01'
        }
      }
    end

    it 'updates the book successful' do
      expect(subject.status).to eq(302)
    end

    it 'saves value to database' do
      subject
      updated_book = Book.find(assigns(:book).id)
      expect(updated_book.name).to eq('ubook')
      expect(updated_book.description).to eq('updates book')
      expect(updated_book.release).to eq(Date.new(2022, 1, 1))
    end

    it 'redirect to show page' do
      subject
      expect(subject).to redirect_to(book_path(assigns(:book).id))
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
end
