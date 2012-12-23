require 'uri'
class Mapgit::Redis
  attr_accessor :redis
  def initialize
    %w[REDIS_URL REDISCLOUD_URL].each do |k|
      if ENV.include? k
        u = URI.parse(ENV[k])
        @redis = Redis.new(host: u.host, port: u.port)
        if u.password
          @redis.auth(u.password)
        end
      end
    end
    @redis ||= Redis.new # Fallback to trying localhost:default
  end

  # Palm anything we're not sure what to do with off to @redis
  def method_missing(sym, *args)
    @redis.send(sym, *args)
  end
end
