# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_up', to: 'users/registrations#new'
    get 'forgot_password', to: 'users/passwords#new'
    get 'reset_password', to: 'users/passwords#edit'
  end

  resources :messages do
    collection do
      get :inbound
      get :inbound_twilio
      get :delivery
      get :status
    end
  end

  resources :reservations, only: [:destroy, :create]

  resources :details do
    collection do
      get :how_it_works
    end
  end

  resources :companies, except: [:destroy]

  root to: 'application#home'
end
