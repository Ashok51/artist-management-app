# frozen_string_literal: true

Rails.application.routes.draw do
  # overriding the registrations controller
  devise_for :users, controllers: { registrations: 'registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :admin do
    resources :users
  end

  resources :artists do
    resources :musics, only: [:index, :create, :show, :update, :destroy]
  end

  # root path of an application
  root to: 'admin/users#index'
end
