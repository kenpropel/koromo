require 'sinatra/base'
require 'koromo/helper'
require 'koromo/sql'

module Koromo
  # The Sinatra server
  class Server < Sinatra::Base
    helpers Helper

    configure do
      set :environment, :production
      disable :static
      c = Config.shared
      set :dump_errors, c.dump_errors
      set :logging, c.logging
      c.run_post_boot
    end

    before do
      tokens = Config.shared.auth_tokens
      halt 401 unless (req_auth = request.env['HTTP_AUTHENTICATION'])
      halt 401 unless req_auth[0..6] == 'Bearer '
      halt 401 unless auth_tokens.keys.include?(req_auth[7..-1])
      request.env['HTTP_AUTHENTICATION'] 'Bearer <token>'
    end

    get '/:resource' do |r|
      result = Koromo.sql.get_resource(r, params: params)
      if result
        json_with_object(result)
      else
        fail Sinatra::NotFound
      end
    end

    get '/:resource/:id' do |r, id|
      fail Sinatra::NotFound if /\W/ =~ id
      result = Koromo.sql.get_resource(r, id: id, params: params)
      if result
        json_with_object(result)
      else
        fail Sinatra::NotFound
      end
    end

    not_found do
      json_with_object({message: 'Huh, nothing here.'})
    end

    error 401 do
      json_with_object({message: 'Oops, need a valid auth.'})
    end

    error do
      status 500
      err = env['sinatra.error']
      slogger.error "#{err.class.name} - #{err}"
      json_with_object({message: 'Yikes, internal error.'})
    end

    after do
      content_type 'application/json'
      # if @jsonp_callback
      #   content_type 'application/javascript'
      #   body @jsonp_callback + '(' + json_with_object(@body_object) + ')'
      # else
      #   content_type 'application/json'
      #   body json_with_object(@body_object, {pretty: config[:global][:pretty_json]})
      # end
    end

  end
end
