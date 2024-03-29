
Rails.application.routes.draw do

  #
  # Devise for user signups and authentication
  # (but exclude it for Tiddlyspot routes)
  #
  constraints(->(req) {
    req.domain != Settings.tiddlyspot_host
  }) do

    devise_for :users, controllers: {
      registrations: :registrations,
      sessions: :sessions,
    }

  end

  #
  # Individual sites on tiddlyhost.com
  #
  constraints(->(req) {
    req.domain == Settings.main_site_host && req.subdomain.present? && req.subdomain != 'www'
  }) do

    match '/', to: 'tiddlywiki#serve', via: [:get, :options]
    match '/tiddlers.json', to: 'tiddlywiki#json_content', via: [:get, :options]
    match '/text/:title.tid', to: 'tiddlywiki#tid_content', via: [:get, :options]

    get '/favicon.ico', to: 'tiddlywiki#favicon'
    get '/download', to: 'tiddlywiki#download'

    post '/', to: 'tiddlywiki#upload_save'
    put '/', to: 'tiddlywiki#put_save'
  end

  #
  # The primary site at tiddlyhost.com
  #
  constraints(->(req) {
    req.domain == Settings.main_site_host && (req.subdomain.blank? || req.subdomain == 'www')
  }) do

    root to: 'home#index'

    get 'home/index'
    get 'home/after_registration'

    get 'about', to: 'home#about'
    get 'donate', to: 'home#donate'

    get 'admin', to: 'admin#index'
    get 'admin/users'
    get 'admin/sites'
    get 'admin/tspot_sites'
    get 'admin/data'
    get 'admin/raw_download'
    get 'admin/csv_data'

    get 'hub', to: 'hub#index'
    get "hub/tag/:tag", to: 'hub#tag', constraints: { tag: %r{.+} }
    get "hub/user/:username", to: 'hub#user'

    resources :sites do
      member do
        get :download
        get :thumb
        get :upload_form
        patch :upload
      end
    end

    if Settings.tiddlyspot_enabled?

      resources :tspot_sites do
        collection do
          get :claim_form
          post :claim

        end

        member do
          get :download
          post :disown

          get :change_password
          patch :change_password_submit
        end
      end

    end

  end

  if Settings.tiddlyspot_enabled?
    #
    # Individual sites on tiddlyspot.com
    #
    constraints(->(req) {
      req.domain == Settings.tiddlyspot_host && req.subdomain.present? && req.subdomain != 'www'
    }) do

      get '/', to: 'tiddlyspot#serve'
      get '/index.html', to: 'tiddlyspot#serve'
      options '/', to: 'tiddlyspot#options'
      get '/favicon.ico', to: 'tiddlyspot#favicon'
      get '/download', to: 'tiddlyspot#download'

      post '/store.cgi', to: 'tiddlyspot#save'
      post '/store.php', to: 'tiddlyspot#save'
    end

    #
    # Main tiddlyspot.com home page (such as it is)
    #
    constraints(->(req) {
      req.domain == Settings.tiddlyspot_host && (req.subdomain.blank? || req.subdomain == 'www')
    }) do

      get '/', to: 'tiddlyspot#home'

    end

  end

  #
  # Error pages
  #
  get '/404', to: "home#error_404"
  get '/422', to: "home#error_422"
  get '/500', to: "home#error_500"

end
