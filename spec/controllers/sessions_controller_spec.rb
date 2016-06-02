require 'spec_helper'

describe SessionsController, type: :controller do
  describe 'Website login' do
    context 'no SAML' do
      it 'user has cookie to login' do
        user = FactoryGirl.create(:user)
        request.session['user_id'] = user.id
        get :new
        expect(response).to redirect_to('/')
      end
      it 'user does not have a cookie to login' do
        get :new
        expect(response).to render_template('new')
      end
    end
  end
  describe 'Website logout' do
    context 'no SAML' do
      before(:each) do
        user = FactoryGirl.create(:user)
        request.session['user_id'] = user.id
        get :new
      end
      it 'user clicks logout' do
        expect(session[:user_id]).to_not eq(nil)
        get :destroy
        expect(response).to redirect_to('/login')
        expect(session[:user_id]).to eq(nil)
      end
      it 'user session timed out' do
        expect(session[:user_id]).to_not eq(nil)
        get :destroy, timeout: '1'
        expect(response).to redirect_to('/login')
        expect(session[:user_id]).to eq(nil)
      end
    end
  end
end
