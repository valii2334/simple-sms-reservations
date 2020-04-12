require 'spec_helper'
require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:company) { create(:company) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in company.user
  end

  describe '#show' do
    it 'is successfull' do
      get :show, params: { id: company.id }

      expect(response).to be_successful
    end

    it 'returns not authorized with another user' do
      second_user = create :user, email: 'valentin@email.com'
      sign_in second_user

      expect do
        get :show, params: { id: company.id }
      end.to raise_error('You are not authorized to access this page.')
    end
  end
end
