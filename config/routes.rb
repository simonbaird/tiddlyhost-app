
Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: :registrations }

  #
  # For individual TiddlyWiki sites
  #
  constraints(->(req) { req.subdomain.present? && req.subdomain != 'www' }) do
    get '/', to: 'home#serve_tiddlywiki'
    post '/', to: 'home#save_tiddlywiki'
  end

  #
  # For the 'main' site
  #
  constraints(->(req) { req.subdomain.blank? || req.subdomain == 'www' }) do
    root to: 'home#index'

    get 'home/index'
    get 'home/after_registration'

    get 'donate', to: 'home#donate'

    get 'admin/users'
    get 'admin/sites'

    get 'hub', to: 'hub#index'
    Settings.hub_tags.keys.each do |k|
      get "hub/#{k}", controller: :hub
    end

    resources :sites
  end

end
