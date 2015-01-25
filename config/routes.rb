Rails.application.routes.draw do
  get "/callback", to: "oauth#callback"
  get "/authorize", to: "oauth#authorize"
  get "/deauthorize", to: "oauth#deauthorize"

  resources :nations

  get "/events", to: "events#index"

  get "/choose_event", to: "events#choose_event"

  get "/findrsvp", to: "events#find_rsvp"
  get "everyone", to: "events#get_all"

  get "events/find_person", to: "events#find_person"

  get "events/processCheckIn", to: "events#processCheckIn"

  get "events/cancel_event", to: "events#new_event"
  get "events/cancel_site", to: "events#new_site"

  root to: "nations#index"
end
