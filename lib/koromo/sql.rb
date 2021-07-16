 require 'tiny_tds'

module Koromo
  def self.sql(conf)
    SQL.client(conf)
  end
  
  class SQL
    def self.client(conf)
      Koromo.logger.info 'Preparing SQL client...'
      @pool ||= {}
      key = "#{conf[:username]}@#{conf[:host]}/#{conf[:database]}"
      Koromo.logger.debug key
      client = @pool[key]
      if client && client.active?
        Koromo.logger.info 'Existing client found in pool.'
      else
        client = SQL.new(conf)
        @pool[key] = client
      end
      Koromo.logger.debug "SQL clients in pool: #{@pool.length}"
      client
    end
    
    def initialize(conf)
      Koromo.logger.info 'Initializing SQL client...'
      TinyTds::Client.default_query_options[:symbolize_keys] = true
      @tds_client = TinyTds::Client.new(conf)
    end

    def active?
      @tds_client.active?
    end

    def query(q)
      Koromo.logger.info 'Executing SQL query...'
      r = @tds_client.execute(q)
      {
        result: r.each,
        fields: r.fields,
        affected_rows: r.affected_rows,
      }
    rescue TinyTds::Error => e
      raise SQLError.new(e)
    end

    def close
      @tds_client.close
    end
  end

  class SQLError < StandardError
    attr_accessor :tinytds
    
    def initialize(err)
      @tinytds = err
    end
  end
end
