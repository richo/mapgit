require 'uri'
class Mapgit::Redis
  attr_accessor :redis
  def initialize
    u = ::Mapgit::REDIS_URL
    @redis = Redis.new(host: u.host, port: u.port)
    if u.password
      @redis.auth(u.password)
    end
    @redis ||= Redis.new # Fallback to trying localhost:default
  end

  # Palm anything we're not sure what to do with off to @redis
  def method_missing(sym, *args)
    @redis.send(sym, *args)
  end
end
