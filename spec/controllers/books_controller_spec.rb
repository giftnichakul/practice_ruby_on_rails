require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  describe 'GET /index' do
    subject { get :index, params: { page: 1 } }

    context 'when user is signed in' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'returns all books' do
        book1 = create(:book)
        book2 = create(:book)

        expect(subject.status).to eq(200)
        expect(assigns(:books)).to include(book1, book2)
      end
    end

    context 'when user not sign in' do
      it 'redirect to log in page' do
        expect(subject.status).to eq(302)
        expect(subject).to redirect_to(new_user_session_path)
      end
    end

  end

  describe 'GET /show' do
    subject { get :show, params: }

    context 'when user sign in' do
      let(:user) { create(:user) }
      before { sign_in user }

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

    context 'when user not sign in' do
      let(:book) { create(:book) }
      let(:params) { { id: book.id } }

      it 'redirect to log in page' do
        expect(subject.status).to eq(302)
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /new' do
    subject { get :new }

    context 'when user sign in' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'renders to new book form' do
        expect(subject.status).to eq(200)
        expect(subject).to render_template(:new)
      end
    end

    context 'when user not sign in' do
      it 'redirect to log in page' do
        expect(subject.status).to eq(302)
        expect(subject).to redirect_to(new_user_session_path)
      end
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

    context 'when user sign in' do
      let(:user) { create(:user) }
      before { sign_in user }

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

      context 'when create with invalid parameter' do
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

    context 'when user not sign in' do

      it 'redirect to log in page' do
        expect(subject.status).to eq(302)
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /edit' do
    subject { get :edit, params: }

    context 'when user sign in' do
      let(:user) { create(:user) }
      before { sign_in user }

      let(:book) { create(:book) }
      let(:params) { { id: book.id } }

      it 'renders to edit book form' do
        expect(subject.status).to eq(200)
        expect(subject).to render_template(:edit)
      end
    end

    context 'when user not sign in' do
      let(:book) { create(:book) }
      let(:params) { { id: book.id } }

      it 'redirect to log in page' do
        expect(subject.status).to eq(302)
        expect(subject).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PUT /update' do
    subject { put :update, params: }

    context 'when user sign in' do
      let(:owner) { create(:user) }
      before { sign_in owner }

      context 'when user update their own book' do
        let!(:book) { create(:book, user: owner) }

        context 'when updates with invalid paramter' do
          let(:params) { { id: book.id, book: { name: '', description: 'invalid name' } } }

          it 'renders the edit page' do
            expect(subject).to render_template(:edit)
            expect(subject.status).to eq(200)
            expect(book.description).not_to eq('invalid name')
          end
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
          expect(owner).to eq(book.user)
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

      context 'when user update other books' do
        let(:other_user) { create(:user) }
        let!(:book) { create(:book, user: other_user) }
        let(:params) { { id: book.id, book: { name: '', description: 'invalid name' } } }

        it 'get authorization error' do
          expect { subject }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    subject { delete :destroy, params: }
    let(:user) { create(:user) }
    let!(:book) { create(:book, user: user) }
    let(:params) { { id: book.id } }

    context 'when user sign in' do
      before { sign_in user }

      context 'when user deletes their own book' do
        it 'deletes the book' do
          expect(subject.status).to eq(302)
          expect(Book.count).to eq(0)
          expect(subject).to redirect_to(books_path)
        end
      end

      context 'when user deletes other books' do
        let(:other_user) { create(:user) }
        let!(:book) { create(:book, user: other_user) }
        let(:params) { { id: book.id } }
        it 'get authorization error' do
          expect { subject }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end
end
