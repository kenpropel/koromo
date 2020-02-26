module Koromo
  def self.config
    Config.shared
  end

  class Config
    # Load Ruby config file
    # @param path [String] config file
    def self.load_config(path)
      raise 'config file missing' unless path
      Koromo.logger.debug("Loading config file: #{path}")
      require File.expand_path(path)
      Koromo.logger.info('Config.load_config done.')
    end

    # Returns the shared instance
    # @return [Koromo::Config]
    def self.shared
      @shared_config ||= Config.new
    end

    # Call this from your config file
    def self.setup
      yield Config.shared
      Koromo.logger.info('Config.setup block executed.')
    end

    attr_accessor :mssql
    attr_accessor :auth_tokens
    attr_accessor :handler_paths
    attr_accessor :dump_errors
    attr_accessor :logging
    attr_accessor :pretty_json

    def initialize
      @auth_tokens = []
      @dump_errors = false
      @logging = false
    end

    def set_post_boot(&block)
      @post_boot_block = block
    end

    def run_post_boot
      @post_boot_block.call if @post_boot_block
      @post_boot_block = nil
    end
  end
end
