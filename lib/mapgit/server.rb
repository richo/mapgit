module Mapgit
  class Server < Sinatra::Base

    set :views,  "views"
    set :public_folder, "public"
    set :static, true
    set :show_exceptions, true
    set :sessions, true

    use OmniAuth::Builder do
        provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
    end

    helpers do
      def current_user
        session[:user]
      end

      def logout!
        session[:user] = nil
      end
    end

    get '/' do
      erb(:index)
    end


    get '/geotags.csv' do
      # Take some aribtrary metadata, turn it into tags and return it as a csv appropriate for R
    end

    get '/github/geotags.csv' do
      # Concoct some neat syntax for referring to a github user, repo, and branch or rev-list
      # Fetch that data from github and do same
    end

    get '/auth/github/callback' do
      session[:user] = request.env['omniauth.auth']
      session[:token] = params[:code]
      redirect '/'
    end

    post '/logout' do
      logout!
      redirect '/'
    end

  end
end

