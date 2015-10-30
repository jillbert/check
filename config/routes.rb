Rails.application.routes.draw do

  get "/callback", to: "oauth#callback"
  get "/authorize", to: "oauth#authorize"
  get "/deauthorize", to: "oauth#deauthorize"

  resources :nations

  get "/choose_site", to: "events#choose_site"
  get "/choose_event", to: "events#choose_event"
  get "/set_event", to: "events#set_event"

  get "events/cancel_event", to: "events#new_event"
  get "events/cancel_site", to: "events#new_site"
  
  get "rsvps/cache", to: "rsvps#cache"
  resources :rsvps
  post "/rsvps/check_in", to: "rsvps#check_in"
  get "rsvps/new_guest", to: "rsvps#new_guest"

  resources :people

  root :to => 'nations#index'
  resources :user_sessions
  resources :users

  get 'admin', to: 'admin#index'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

end
