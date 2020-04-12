require 'spec_helper'
require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  let(:company) { create :company }

  before(:each) do
    sign_in company.user
  end

  context '#show' do
    describe 'Get company' do
      it 'is successful' do
        get company_path(id: company.id), params: {}
        expect(response).to be_successful
      end

      it 'returns not authorized with another user' do
        second_user = create :user, email: 'valentin@email.com'
        sign_in second_user

        expect do
          get company_path(id: company.id), params: {}
        end.to raise_error('You are not authorized to access this page.')
      end
    end
  end
end
