module Mapgit
  class Server < Sinatra::Base

    set :views,  "views"
    set :public_folder, "public"
    set :static, true
    set :show_exceptions, true
    set :sessions, true

    unless ENV['GMAPS_API_KEY']
      raise "GMAPS_API_KEY unset"
    end

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
      username = params[:user]
      hash_name = "#{username}:tags"
      lines = []
      refs = params[:refs]
      if refs
        refs.split("|").each do |ref|
          lines << "#{ref},#{redis.hget(hash_name, ref)}"
        end
      else
        redis.hgetall(hash_name).each do |hash, tag|
          lines << "#{hash},#{tag}"
        end
      end
      halt lines.join("\n")
    end

    get '/geotags/map' do
      if current_user
        username = current_user[:nickname]
      elsif params[:user]
        username = params[:user]
      else
        raise "No username"
      end

      hash_name = "#{username}:tags"
      tags = []

      redis.hgetall(hash_name).each do |hash, tag|
        x, y = tag.split(",")
        tags << [x.to_f, y.to_f]
      end

      render(:"geotags/map", :locals => {:tags => tags}, :layout => nil)
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
