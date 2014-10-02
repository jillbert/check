Rails.application.routes.draw do
  get "/callback", to: "oauth#callback"
  get "/authorize", to: "oauth#authorize"
  get "/deauthorize", to: "oauth#deauthorize"

  resources :nations

  get "/events", to: "events#index"

  get "/choose_event", to: "events#choose_event"

  get "/findrsvp", to: "events#find_rsvp"

  get "events/find_person", to: "events#find_person"

  get "events/processCheckIn", to: "events#processCheckIn"


  root to: "nations#index"
end
