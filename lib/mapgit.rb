require 'omniauth'
require 'omniauth-github'
require 'sinatra'
require 'redis'
require 'redis-store'
require 'redis-rack'
require 'json'

module Mapgit
  REDIS_URL = lambda {
    %w[REDIS_URL REDISCLOUD_URL].each do |k|
      if ENV.include? k
        return URI.parse(ENV[k])
      end
    end
  raise "No redis url given"
  }.call
end

Dir[File.expand_path("../mapgit/models/*", __FILE__)].each do |f|
  require f
end

%w[server redis].each do |f|
  require File.expand_path("../mapgit/#{f}", __FILE__)
end
