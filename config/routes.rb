Rails.application.routes.draw do
  get 'user_sessions/new'

  get 'user_sessions/create'

  get 'user_sessions/destroy'

  resources :users

  get "/callback", to: "oauth#callback"
  get "/authorize", to: "oauth#authorize"
  get "/deauthorize", to: "oauth#deauthorize"

  resources :nations

  get "/events", to: "events#index"

  get "/choose_event", to: "events#choose_event"

  get "/findrsvp", to: "events#find_rsvp"
  get "everyone", to: "events#get_all"
  get "new_rsvp", to: "events#new_rsvp"

  get "events/find_person", to: "events#find_person"
  get "events/make_new_rsvp", to: "events#make_new_rsvp"
  get "events/processCheckIn", to: "events#processCheckIn"
  get "events/cache", to: "events#create_cache"
  
  get "events/cancel_event", to: "events#new_event"
  get "events/cancel_site", to: "events#new_site"

  root :to => 'users#index'
  resources :user_sessions
  resources :users

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

end
