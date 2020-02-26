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
      c = Koromo.config
      set :dump_errors, c.dump_errors
      set :logging, c.logging
      c.run_post_boot
    end

    before do
      Koromo.logger.info 'Filter: before...'
      halt 401 unless (req_auth = request.env['HTTP_AUTHORIZATION'])
      halt 401 unless req_auth[0..6] == 'Bearer '
      c = Koromo.config
      if (auth = c.auth_tokens[req_auth[7..-1]])
        c.mssql[:username] = auth[:username]
        c.mssql[:password] = auth[:password]
        Koromo.logger.info 'Authorization successful.'
        Koromo.logger.debug "Auth token matched to SQL user: #{auth[:username]}"
      else
        halt 403
      end
      halt 415 unless request.media_type == 'application/json'
    end

    # Primary usage, accepts SQL query; submit JSON in body
    # {"query": "SELECT * FROM table"}
    post '/query' do
      j = parse_json(request.body)
      sql = SQL.new(Config.shared.mssql)
      result = sql.query(j[:query])
      if result
        @return_obj = result
      else
        @return_obj = {result: 'nil'}
      end
    end

    # Pre-configured SQL queries
    post '/preset/:name' do |name|
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
      body json_with_object(@return_obj)
    end
  end
end
