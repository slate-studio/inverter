Rails.application.routes.draw do
  root "pages#about"
  get "excluded",   to: "pages#excluded"
  get "about",      to: "about#index"
  get "meta_tags",  to: "meta_tags#index"
end
