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

      def redis
        @redis ||= Redis.new
      end
    end

    get '/' do
      erb(:index)
    end

    get '/geotags' do
      if params[:user]
        username = params[:user]
      elsif current_user
        username = current_user.info[:nickname]
      else
        halt 403, "Login fool!"
      end

      hash_name = "#{username}:tags"

      erb(:geotags, :locals => { :tags => redis.hgetall(hash_name) })
    end


    get '/geotags/upload' do
      erb(:"geotags/upload")
    end

    post '/geotags/upload' do
      halt 403, "Login fool!" unless current_user

      begin
        hash_name = "#{current_user.info[:nickname]}:tags"
        params[:tags].lines.each do |line|
          tag = ::Mapgit::Tag.from_line(line)
          redis.hmset hash_name, tag.hash, tag.tag
        end
        redirect '/geotags'
      rescue Exception => e
        halt 500, "Invalid data yo\n\n" + e.to_s
      end

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
