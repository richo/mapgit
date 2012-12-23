require 'omniauth'
require 'omniauth-github'
require 'sinatra'

module Mapgit
end

%w[server].each do |f|
  require File.expand_path("../mapgit/#{f}", __FILE__)
end
