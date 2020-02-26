require 'json'

module Koromo
  module Helper
    def parse_json(str)
      JSON.parse(str, {symbolize_names: true})
    rescue => e
      Koromo.logger.warn "#{e.class.name} - #{e}"
      halt 415
    end

    # Convert object into JSON, optionally pretty-format
    # @param obj [Object] any Ruby object
    # @param opts [Hash] any JSON options
    # @return [String] JSON string
    def json_with_object(obj, pretty: nil, opts: nil)
      return '{}' if obj.nil?
      pretty ||= Koromo.config.pretty_json
      if pretty
        opts = {
          indent: '  ',
          space: ' ',
          object_nl: "\n",
          array_nl: "\n"
        }
      end
      JSON.fast_generate(json_format_value(obj), opts)
    end

    # Return Ruby object/value to JSON standard format
    # @param val [Object]
    # @return [Object]
    def json_format_value(val)
      case val
      when Array
        val.map { |v| json_format_value(v) }
      when Hash
        val.reduce({}) { |h, (k, v)| h.merge({k => json_format_value(v)}) }
      when BigDecimal
        # val.to_s('F')
        val.to_f
      when String
        val.encode!('UTF-8', {invalid: :replace, undef: :replace})
      when Time
        val.utc.iso8601
      else
        val
      end
    end
  end
end
