# frozen_string_literal: true

Rails.application.routes.draw do
  # overriding the registrations controller
  devise_for :users, controllers: { registrations: 'registrations' }

  namespace :admin do
    resources :users
  end

  # for csv import export
  resources :artists do
    collection do
      get :export
      post :import
    end
  end

  resources :artists do
    resources :musics, only: %i[index create show update destroy]
  end

  # Default root route for unauthenticated users
  root to: 'home#index'

  # routes to manage individual music record by a particular 'artist' user
  resources :musics
end
