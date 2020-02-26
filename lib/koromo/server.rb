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
      Koromo.logger.info 'Router: incoming query request...'
      request.body.rewind
      j = parse_json(request.body.read)
      halt 400 if j[:query].nil?
      start = Time.now
      Koromo.logger.debug "SQL query: #{j[:query]}"
      sql = Koromo.sql(Koromo.config.mssql)
      result = sql.query(j[:query])
      finish = Time.now
      json_with_object({ok: true, result: result, query_time: finish - start, result_size: result.length})
    end

    # Pre-configured SQL queries
    # post '/preset/:name' do |name|
    # end

    not_found do
      json_with_object({message: 'Huh, nothing here.'})
    end

    error 400 do
      json_with_object({message: 'Wait, what?'})
    end

    error 401 do
      json_with_object({message: 'Oops, need a valid auth.'})
    end

    error 403 do
      json_with_object({message: 'Nah, not for you.'})
    end

    error 415 do
      json_with_object({message: 'Uh, right over my head.'})
    end

    error do
      status 500
      err = env['sinatra.error']
      Koromo.logger.error "#{err.class.name} - #{err}"
      json_with_object({message: 'Yikes, internal error.'})
    end

    error TinyTds::Error do
      status 502
      err = env['sinatra.error']
      Koromo.logger.warn "#{err.class.name} - #{err}"
      json_with_object({ok: false, error: "#{err}"})
    end

    error SQLError do
      status 400
      err = env['sinatra.error'].tinytds
      Koromo.logger.warn "#{err.class.name} - #{err}"
      json_with_object({ok: false, error: "#{err}"})
    end

    after do
      Koromo.logger.info 'Filter: after...'
      content_type 'application/json'
    end
  end
end
