require 'cgi'

module VCAP::CloudController::RestController
  class CommonParams
    # noinspection RubyLiteralArrayInspection
    MAGIC_PARAMS = [
      ['inline-relations-depth', Integer],
      ['page', Integer],
      ['results-per-page', Integer],
      ['q', String],
      ['order-direction', String],
      ['orphan-relations', Integer],
      ['exclude-relations', String],
      ['include-relations', String],
    ]

    def initialize(logger)
      @logger = logger
    end

    def parse(params, query_string=nil, legacy: true)
      @logger.debug "parse_params: #{params} #{query_string}"
      res = {}
      MAGIC_PARAMS.each do |key, klass|
        val = params[key]
        if val
          val = Object.send(klass.name, val) if legacy
          res[key.underscore.to_sym] = val
        end
      end

      if res[:q] && query_string && query_string.count('q=') > 1
        res[:q] = CGI.parse(query_string)['q']
      end

      # relationship names should be specified as a comma separated list
      if res[:exclude_relations]
        res[:exclude_relations] = res[:exclude_relations].split(',')
      end

      if res[:include_relations]
        res[:include_relations] = res[:include_relations].split(',')
      end

      res
    end
  end
end
