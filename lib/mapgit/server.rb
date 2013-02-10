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

    set :github_options, {
      :scope     => 'user',
      :secret    => ENV['GITHUB_SECRET'],
      :client_id => ENV['GITHUB_KEY'],
    }

    register Sinatra::Auth::Github

    helpers do
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
      elsif github_user
        username = github_user.login
      else
        halt 403, "Login fool!"
      end

      hash_name = "#{username}:tags"

      erb(:geotags, :locals => { :tags => redis.hgetall(hash_name) })
    end

    get '/geotags/upload' do
      erb(:"geotags/upload")
    end

    get '/auth/github' do
      session[:user] = authenticate!
      require 'pry'
      binding.pry
      redirect '/'
    end

    post '/geotags/upload' do
      halt 403, "Login fool!" unless github_user

      begin
        hash_name = "#{github_user.login}:tags"
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
      if github_user
        username = github_user.login
      elsif params[:user]
        username = params[:user]
      else
        raise "No username"
      end

      hash_name = "#{username}:tags"
      tags = []

      center = [0, 0]

      redis.hgetall(hash_name).each do |hash, tag|
        x, y = tag.split(",").map(&:to_f)
        center[0] += x
        center[1] += y

        tags << [x, y]
      end

      if tags.length > 0
        center[0] /= tags.length
        center[1] /= tags.length
      else
        raise "No tags fetched"
      end

      erb(:"geotags/map", :locals => {:tags => tags, :center => center}, :layout => false)
    end

    get '/github/geotags.csv' do
      # Concoct some neat syntax for referring to a github user, repo, and branch or rev-list
      # Fetch that data from github and do same
    end

    post '/logout' do
      logout!
      redirect '/'
    end

  end
end
