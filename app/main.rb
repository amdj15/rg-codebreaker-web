require './app/controller'
require './app/router'
require './app/actions'
require 'rack'
require "codebreaker"
require 'json/ext'
require 'erb'

class App
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)

    @routes = Router.new
    @actions = Actions.new
  end

  def response
    action = @routes.check(@request.path, @request)
    res = @actions.send(action[0], *action[1]);

    Rack::Response.new(*res)
  end
end