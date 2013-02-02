require 'omniauth'
require 'omniauth-github'
require 'sinatra'
require 'redis'
require 'json'

module Mapgit
end

Dir[File.expand_path("../mapgit/models/*", __FILE__)].each do |f|
  require f
end

%w[server redis].each do |f|
  require File.expand_path("../mapgit/#{f}", __FILE__)
end
