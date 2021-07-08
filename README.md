# koromo

[![Gem Version](https://badge.fury.io/rb/koromo.svg)](https://badge.fury.io/rb/koromo) [![Code Climate](https://codeclimate.com/github/kenjij/koromo/badges/gpa.svg)](https://codeclimate.com/github/kenjij/koromo)

A proxy server for MS SQL Server to present as a RESTful service.

## Requirements

- [Ruby](https://www.ruby-lang.org/) 2.7 <=
- [Kajiki](https://kenjij.github.io/kajiki/) 1.2 <=
- [Sinatra](http://www.sinatrarb.com) 2.1 <=
- [TinyTDS](https://github.com/rails-sqlserver/tiny_tds)

## Getting Started

### Install

```
$ gem install koromo
```

### Configure

Create a configuration file following the example below.

```ruby
# Configure application logging
Koromo.logger = Logger.new(STDOUT)
Koromo.logger.level = Logger::DEBUG

Koromo::Config.setup do |c|
  # MS-SQL settings
  c.mssql = {
    host: '192.168.0.10', # Used if :dataserver blank. Can be an host name or IP.
    port: 1433, # Defaults to 1433. Only used if :host is used.
    database: 'master', # The default database to use.
    login_timeout: 10, # Seconds to wait for login. Default to 60 seconds.
    # timeout: 5, # Seconds to wait for a response to a SQL command. Default 5 seconds.
    # max_connections: 4, # Connection pool size Default is 4.
  }
  # Match incoming request with "Authorization: Bearer <token>" HTTP header
  c.auth_tokens = {
    'someSTRING1234' => {
      username: 'user_one',
      password: 'PaSsWoRd1234',
    },
    'OTHERstring987' => {
      username: 'user_two',
      password: 'pAsSwOrD5678',
    },
  }
  # Paths to handlers
  # c.handler_paths = [
  #   File.expand_path('../../handlers', __FILE__)
  # ]
  # HTTP server (Sinatra) settings
  c.dump_errors = true
  c.logging = true
end

Koromo::Config.shared.set_post_boot do
  # Post boot routine (called from Server.configure block)
  # if ENV['APP_ENV'] == 'production'
  #   require 'production_gem'
  #   GC::Profiler.enable
  # end
end
```

### Use

```
$ koromo start -c config.rb
```

### Examples

Config file.

```
$ koromo_config
```

